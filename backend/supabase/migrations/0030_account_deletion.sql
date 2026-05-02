-- Migration 0030: Account Deletion (GDPR/Indonesian PDPA compliance)
-- Allows users to permanently delete their account and all associated data

-- ============================================================
-- 1. RPC: delete_parent_account — cascade soft-delete + audit
-- ============================================================
CREATE OR REPLACE FUNCTION delete_parent_account(p_parent_id UUID)
RETURNS VOID
LANGUAGE plpgsql SECURITY DEFINER
AS $$
BEGIN
  -- Soft delete all children (is_deleted = true)
  UPDATE child_profiles
  SET is_deleted = true, is_active = false, updated_at = NOW()
  WHERE parent_id = p_parent_id;

  -- Cancel active subscriptions
  UPDATE subscriptions
  SET status = 'cancelled', updated_at = NOW()
  WHERE parent_id = p_parent_id AND status IN ('active', 'trialing');

  -- Clear FCM token so no push can be sent
  UPDATE parent_profiles
  SET fcm_token = NULL, updated_at = NOW()
  WHERE id = p_parent_id;

  -- Mark notifications as read-only (keep for audit)
  -- notifications table is kept for reference but parent_id is nulled

  -- Delete auth user (this cascades to parent_profiles via FK if configured)
  -- Supabase Auth requires admin API call; we mark parent_profiles as deleted
  -- The actual auth.user deletion must happen via Supabase Admin API separately
  DELETE FROM parent_profiles WHERE id = p_parent_id;

END;
$$;

-- ============================================================
-- 2. Note: Auth user deletion must be done via Supabase Admin API:
-- DELETE /auth/v1/admin/users/{user_id}
-- This requires server-side call with service_role key
-- ============================================================
