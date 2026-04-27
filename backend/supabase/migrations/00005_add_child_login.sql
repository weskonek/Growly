-- Growly Child Login Function
-- Allows child app to authenticate using child_id and PIN

-- ============================================
-- FUNCTION: Verify child PIN and return profile
-- ============================================
CREATE OR REPLACE FUNCTION public.verify_child_pin(
    p_child_id UUID,
    p_pin TEXT
)
RETURNS TABLE (
    success BOOLEAN,
    child_id UUID,
    name TEXT,
    age_group INTEGER,
    avatar_url TEXT,
    error_message TEXT
) AS $$
DECLARE
    v_child RECORD;
BEGIN
    -- Find child by ID
    SELECT id, name, pin_hash, age_group, avatar_url, is_active
    INTO v_child
    FROM public.child_profiles
    WHERE id = p_child_id;

    -- Check if child exists
    IF v_child IS NULL THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, NULL::INTEGER, NULL::TEXT, 'Profil anak tidak ditemukan'::TEXT;
        RETURN;
    END IF;

    -- Check if child is active
    IF NOT v_child.is_active THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, NULL::INTEGER, NULL::TEXT, 'Profil tidak aktif'::TEXT;
        RETURN;
    END IF;

    -- Check if PIN is set
    IF v_child.pin_hash IS NULL OR v_child.pin_hash = '' THEN
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, NULL::INTEGER, NULL::TEXT, 'PIN belum diatur'::TEXT;
        RETURN;
    END IF;

    -- Verify PIN using bcrypt
    IF crypt(p_pin, v_child.pin_hash) = v_child.pin_hash THEN
        RETURN QUERY SELECT TRUE, v_child.id, v_child.name, v_child.age_group, v_child.avatar_url, NULL::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, NULL::UUID, NULL::TEXT, NULL::INTEGER, NULL::TEXT, 'PIN salah'::TEXT;
    END IF;

    RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FUNCTION: Set or update child PIN
-- ============================================
CREATE OR REPLACE FUNCTION public.set_child_pin(
    p_child_id UUID,
    p_pin TEXT,
    p_parent_id UUID
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_pin_hash TEXT;
BEGIN
    -- Verify parent owns this child
    IF NOT EXISTS (
        SELECT 1 FROM public.child_profiles
        WHERE id = p_child_id AND parent_id = p_parent_id
    ) THEN
        RETURN QUERY SELECT FALSE, 'Akses ditolak'::TEXT;
        RETURN;
    END IF;

    -- Validate PIN length (4-6 digits)
    IF LENGTH(p_pin) < 4 OR LENGTH(p_pin) > 6 THEN
        RETURN QUERY SELECT FALSE, 'PIN harus 4-6 digit'::TEXT;
        RETURN;
    END IF;

    -- Validate PIN is numeric
    IF p_pin !~ '^[0-9]+$' THEN
        RETURN QUERY SELECT FALSE, 'PIN harus berupa angka'::TEXT;
        RETURN;
    END IF;

    -- Hash the PIN
    v_pin_hash := crypt(p_pin, gen_salt('bf'));

    -- Update the PIN
    UPDATE public.child_profiles
    SET pin_hash = v_pin_hash, updated_at = NOW()
    WHERE id = p_child_id;

    RETURN QUERY SELECT TRUE, 'PIN berhasil diatur'::TEXT;
    RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FUNCTION: Get child profile for parent
-- ============================================
CREATE OR REPLACE FUNCTION public.get_children_for_parent(
    p_parent_id UUID
)
RETURNS TABLE (
    id UUID,
    name TEXT,
    birth_date DATE,
    age_group INTEGER,
    avatar_url TEXT,
    is_active BOOLEAN,
    created_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        cp.id,
        cp.name,
        cp.birth_date,
        cp.age_group,
        cp.avatar_url,
        cp.is_active,
        cp.created_at
    FROM public.child_profiles cp
    WHERE cp.parent_id = p_parent_id
    ORDER BY cp.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
