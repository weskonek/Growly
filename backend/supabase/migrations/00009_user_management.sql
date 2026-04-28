-- Growly User Management & RLS Consolidation
-- Migration 0009: Completes RBAC, consent logs RLS, subscriptions RLS,
-- audit logs RLS, PIN hash helper, and documents the user auth flows.
--
-- STATUS: APPLIED TO DATABASE (2026-04-29)
-- Apply via: supabase db push OR psql directly to Supabase project.
--
-- IMPORTANT: Tables use these FK columns (verified against live DB):
--   audit_logs    → user_id (NOT parent_id)
--   consent_logs → parent_id
--   subscriptions → parent_id
--   ai_tutor_messages → session_id + child_id (newly added)
--   all child_* tables → child_id

-- ================================================================
-- SECTION 1: Consent Logs — RLS Policies
-- consent_logs uses parent_id column (verified in DB)
-- ================================================================

ALTER TABLE consent_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Parents can insert consent logs" ON consent_logs;
CREATE POLICY "Parents can insert consent logs"
  ON consent_logs FOR INSERT
  WITH CHECK (parent_id = auth.uid());

DROP POLICY IF EXISTS "Parents can view consent logs" ON consent_logs;
CREATE POLICY "Parents can view consent logs"
  ON consent_logs FOR SELECT
  USING (
    parent_id = auth.uid()
    OR auth.jwt()->>'role' = 'service_role'
  );

DROP POLICY IF EXISTS "Parents can update consent logs" ON consent_logs;
CREATE POLICY "Parents can update consent logs"
  ON consent_logs FOR UPDATE
  USING (parent_id = auth.uid());

DROP POLICY IF EXISTS "Parents can delete consent logs" ON consent_logs;
CREATE POLICY "Parents can delete consent logs"
  ON consent_logs FOR DELETE
  USING (parent_id = auth.uid());

-- ================================================================
-- SECTION 2: Subscriptions — RLS Policies
-- subscriptions uses parent_id column (verified in DB)
-- ================================================================

ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Parents can view subscription" ON subscriptions;
CREATE POLICY "Parents can view subscription"
  ON subscriptions FOR SELECT
  USING (parent_id = auth.uid());

DROP POLICY IF EXISTS "Service role can manage subscriptions" ON subscriptions;
CREATE POLICY "Service role can manage subscriptions"
  ON subscriptions FOR ALL
  USING (auth.jwt()->>'role' = 'service_role')
  WITH CHECK (auth.jwt()->>'role' = 'service_role');

-- ================================================================
-- SECTION 3: Audit Logs — RLS Policies
-- audit_logs uses user_id column (FK to auth.users), NOT parent_id
-- (verified in DB: no parent_id column exists)
-- ================================================================

ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Service role can insert audit logs" ON audit_logs;
CREATE POLICY "Service role can insert audit logs"
  ON audit_logs FOR INSERT
  WITH CHECK (auth.jwt()->>'role' = 'service_role');

DROP POLICY IF EXISTS "Users can view their audit logs" ON audit_logs;
CREATE POLICY "Users can view their audit logs"
  ON audit_logs FOR SELECT
  USING (user_id = auth.uid());

DROP POLICY IF EXISTS "Service role can view audit logs" ON audit_logs;
CREATE POLICY "Service role can view audit logs"
  ON audit_logs FOR SELECT
  USING (auth.jwt()->>'role' = 'service_role');

-- ================================================================
-- SECTION 4: AI Tutor Sessions & Messages — RLS Policies
-- ai_tutor_messages currently: id, session_id, role, content, created_at
-- Add child_id column for simpler RLS scoping via subquery
-- ================================================================

ALTER TABLE ai_tutor_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_tutor_messages ENABLE ROW LEVEL SECURITY;

-- Add child_id to ai_tutor_messages if not exists
DO $$ BEGIN
  ALTER TABLE ai_tutor_messages ADD COLUMN IF NOT EXISTS child_id UUID;
EXCEPTION WHEN duplicate_column THEN NULL;
END $$;

-- Backfill child_id from ai_tutor_sessions
UPDATE ai_tutor_messages m
SET child_id = s.child_id
FROM ai_tutor_sessions s
WHERE m.session_id = s.id AND m.child_id IS NULL;

-- Existing SELECT policies for ai_tutor_sessions/messages are correct
-- (scoped via child_id → parent_id → auth.uid())

-- ================================================================
-- SECTION 5: Badges — RLS Policies
-- CRITICAL: existing "Badges are viewable by child app" allowed ANY
-- authenticated user to read ALL badges. Fixed to scope to owner's children.
-- ================================================================

ALTER TABLE badges ENABLE ROW LEVEL SECURITY;

-- Replace overly-permissive child app policy
DROP POLICY IF EXISTS "Badges are viewable by child app" ON badges;
CREATE POLICY "Badges are viewable by child app"
  ON badges FOR SELECT
  USING (
    child_id IN (
      SELECT id FROM child_profiles
      WHERE parent_id = auth.uid()
    )
    OR auth.jwt()->>'role' = 'service_role'
  );

DROP POLICY IF EXISTS "Badges are viewable by parent" ON badges;
CREATE POLICY "Badges are viewable by parent"
  ON badges FOR SELECT
  USING (
    child_id IN (
      SELECT id FROM child_profiles
      WHERE parent_id = auth.uid()
    )
    OR auth.jwt()->>'role' = 'service_role'
  );

-- ================================================================
-- SECTION 6: Helper Functions
-- ================================================================

CREATE OR REPLACE FUNCTION public.hash_pin(p_pin TEXT)
RETURNS TEXT AS $$
BEGIN
  IF p_pin !~ '^[0-9]{4,6}$' THEN
    RAISE EXCEPTION 'PIN must be 4-6 numeric digits';
  END IF;
  RETURN crypt(p_pin, gen_salt('bf', 10));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.check_pin(p_pin TEXT, p_hash TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN crypt(p_pin, p_hash) = p_hash;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER IMMUTABLE;

-- ================================================================
-- SECTION 7: Performance Indexes
-- ================================================================
CREATE INDEX IF NOT EXISTS idx_child_profiles_parent
  ON child_profiles(parent_id)
  WHERE is_active = TRUE AND is_deleted = FALSE;

CREATE INDEX IF NOT EXISTS idx_screen_time_child_date
  ON screen_time_records(child_id, date DESC);

CREATE INDEX IF NOT EXISTS idx_sessions_child_created
  ON learning_sessions(child_id, started_at DESC);

CREATE INDEX IF NOT EXISTS idx_ai_sessions_child
  ON ai_tutor_sessions(child_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_consent_logs_parent_created
  ON consent_logs(parent_id, created_at DESC);

-- ================================================================
-- SECTION 8: Updated_at Triggers (idempotent)
-- ================================================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS child_profiles_updated_at ON child_profiles;
CREATE TRIGGER child_profiles_updated_at
  BEFORE UPDATE ON child_profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS learning_progress_updated_at ON learning_progress;
CREATE TRIGGER learning_progress_updated_at
  BEFORE UPDATE ON learning_progress
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS learning_sessions_updated_at ON learning_sessions;
CREATE TRIGGER learning_sessions_updated_at
  BEFORE UPDATE ON learning_sessions
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS screen_time_records_updated_at ON screen_time_records;
CREATE TRIGGER screen_time_records_updated_at
  BEFORE UPDATE ON screen_time_records
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ================================================================
-- USER AUTHENTICATION FLOWS (Documentation)
-- ================================================================
--
-- FLOW 1: Parent Signup
--   POST /auth/v1/signup { email, password }
--   → Supabase Auth creates auth.users entry
--   → Trigger: on_auth_user_created → inserts parent_profiles
--   → RLS: parent_profiles INSERT requires auth.uid() = id (auto via trigger)
--
-- FLOW 2: Parent Login
--   POST /auth/v1/token?grant_type=password { email, password }
--   → Returns JWT with sub=user_id, role=authenticated
--   → App stores session (supabase_flutter auto-handles)
--   → All subsequent queries use JWT → RLS enforces parent_id = auth.uid()
--
-- FLOW 3: Add Child Profile
--   POST /rest/v1/child_profiles
--   JWT: authenticated (parent role)
--   RLS INSERT policy: parent_id must = auth.uid()
--   → Parent must pass parent_id from their auth user ID
--   → App does: parentId: Supabase.instance.client.auth.currentUser!.id
--
-- FLOW 4: Child Login (PIN Gate)
--   App: user enters PIN
--   → RPC verify_child_pin(p_child_id, p_pin)
--   → DB: crypt(p_pin, hash) = hash → returns child profile
--   → RLS: RPC uses SECURITY DEFINER (bypasses RLS, but still validates PIN)
--   → App: stores child_id in flutter_secure_storage
--
-- FLOW 5: Child App Accesses Data
--   JWT: authenticated (parent app session, NOT child)
--   Child app uses child_id from storage to query via parent JWT
--   → RLS: queries filtered by parent_id (from child_profiles.parent_id)
--   → Child cannot access other children's data
--
-- FLOW 6: AI Tutor Messages
--   POST /functions/v1/ai-tutor { child_id, question }
--   JWT: authenticated (parent or child)
--   Edge function: validates child ownership via parent_id check
--   → Inserts ai_tutor_messages with service_role key
--   → RLS: messages accessible by parent of the child
--
-- KEY SECURITY POINTS:
--   1. All data is scoped to parent_id (parent) or child_id (child via parent FK)
--   2. Child app does NOT get its own JWT — uses parent's session
--   3. PIN verification happens server-side only (bcrypt hash never exposed)
--   4. Service role key ONLY used in: edge functions, admin_web, migrations
--   5. Anon key: sufficient for all read operations where RLS allows access
--   6. Never trust client-provided parent_id — always derive from auth.uid()
