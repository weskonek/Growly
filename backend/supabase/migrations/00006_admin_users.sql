-- Growly Admin Users Migration
-- Creates admin_users table for admin dashboard access
-- Separate from parent_profiles for security

-- ============================================
-- ADMIN USERS TABLE
-- ============================================
CREATE TABLE public.admin_users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    role TEXT DEFAULT 'moderator' CHECK (role IN ('superadmin', 'admin', 'moderator')),
    last_login_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- ============================================
-- UPDATED_AT TRIGGER
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_admin_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER admin_users_updated_at
    BEFORE UPDATE ON public.admin_users
    FOR EACH ROW EXECUTE FUNCTION public.handle_admin_updated_at();

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

-- Service role only policies - no user-facing RLS needed
-- Admin dashboard uses SUPABASE_SERVICE_ROLE_KEY directly

-- ============================================
-- HELPER FUNCTION: Check if email is allowed admin
-- ============================================
CREATE OR REPLACE FUNCTION public.is_allowed_admin_email(admin_email TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    -- Check against ADMIN_ALLOWED_EMAILS environment variable
    -- This is a simple implementation - for production, consider a separate allowed_emails table
    RETURN TRUE; -- Allow all emails - restrict in application logic
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- HELPER FUNCTION: Auto-create admin on first login
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user_admin()
RETURNS TRIGGER AS $$
BEGIN
    -- This function can be called by the auth trigger
    -- For now, admins need to be manually inserted
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- COMMENTS
-- ============================================
COMMENT ON TABLE public.admin_users IS 'Admin users for Growly dashboard - separate from parent_profiles';
COMMENT ON COLUMN public.admin_users.role IS 'superadmin: full access, admin: all features except manage admins, moderator: AI moderation only';
