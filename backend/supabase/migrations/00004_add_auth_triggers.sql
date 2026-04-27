-- Growly Auth Triggers Migration
-- Automatically creates parent_profiles when users sign up via Supabase Auth

-- ============================================
-- FUNCTION: Handle new user signup
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Insert into parent_profiles when a new user signs up
    INSERT INTO public.parent_profiles (id, name, email)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'name', ''),
        NEW.email
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- TRIGGER: Auto-create parent profile on signup
-- ============================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- FUNCTION: Handle user deletion
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_deleted_user()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete child profiles cascade (RLS will handle access)
    DELETE FROM public.child_profiles WHERE parent_id = OLD.id;
    -- Parent profile is deleted via CASCADE from auth.users
    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- TRIGGER: Handle user update
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_updated_user()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.parent_profiles
    SET
        name = COALESCE(NEW.raw_user_meta_data->>'name', name),
        email = NEW.email,
        updated_at = NOW()
    WHERE id = NEW.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_updated ON auth.users;

CREATE TRIGGER on_auth_user_updated
    AFTER UPDATE ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_user();
