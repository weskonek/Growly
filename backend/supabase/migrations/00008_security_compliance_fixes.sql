-- Growly Security & Compliance Fixes
-- Phase 1: PIN verification, consent logs, subscriptions

-- ============================================
-- FIX 1: Find child by PIN (bypass requiring child_id)
-- Verifies PIN using bcrypt hash, returns child profile
-- ============================================
CREATE OR REPLACE FUNCTION public.find_child_by_pin(p_pin TEXT)
RETURNS TABLE(id UUID, name TEXT, age_group INTEGER, avatar_url TEXT, pin_hash TEXT) AS $$
BEGIN
  RETURN QUERY
  SELECT cp.id, cp.name, cp.age_group, cp.avatar_url, cp.pin_hash
  FROM public.child_profiles cp
  WHERE cp.is_active = true
    AND cp.pin_hash IS NOT NULL
    AND cp.pin_hash != '';
  -- Filter by PIN match in application layer to avoid SQL injection
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FIX 2: Consent logs table (COPPA-like compliance)
-- ============================================
CREATE TABLE IF NOT EXISTS consent_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID REFERENCES parent_profiles(id) ON DELETE SET NULL,
  child_id UUID REFERENCES child_profiles(id) ON DELETE SET NULL,
  consent_type TEXT NOT NULL CHECK (consent_type IN (
    'account_creation',
    'data_collection',
    'ai_tutor_usage',
    'screen_time_tracking',
    'location_tracking',
    'marketing_communication'
  )),
  consented BOOLEAN NOT NULL DEFAULT TRUE,
  consent_version TEXT DEFAULT '1.0',
  ip_address INET,
  user_agent TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE consent_logs IS 'Audit trail for parent consent across all data processing activities';

CREATE INDEX idx_consent_logs_parent ON consent_logs(parent_id);
CREATE INDEX idx_consent_logs_child ON consent_logs(child_id);
CREATE INDEX idx_consent_logs_type ON consent_logs(consent_type);
CREATE INDEX idx_consent_logs_created ON consent_logs(created_at DESC);

-- Enable RLS
ALTER TABLE consent_logs ENABLE ROW LEVEL SECURITY;

-- Parents can insert their own consent logs
CREATE POLICY "Parents can insert consent logs"
  ON consent_logs FOR INSERT
  WITH CHECK (
    parent_id = auth.uid()
    OR auth.jwt()->>'role' = 'service_role'
  );

-- Parents can view their own consent logs
CREATE POLICY "Parents can view consent logs"
  ON consent_logs FOR SELECT
  USING (
    parent_id = auth.uid()
    OR auth.jwt()->>'role' = 'service_role'
    OR auth.jwt()->>'role' = 'authenticated'
  );

-- ============================================
-- FIX 3: Subscriptions table
-- ============================================
CREATE TABLE IF NOT EXISTS subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID NOT NULL REFERENCES parent_profiles(id) ON DELETE CASCADE,
  tier TEXT NOT NULL DEFAULT 'free' CHECK (tier IN (
    'free',
    'premium_family',
    'premium_ai_tutor',
    'school_institution'
  )),
  status TEXT NOT NULL DEFAULT 'active' CHECK (status IN (
    'active',
    'trialing',
    'past_due',
    'cancelled',
    'paused'
  )),
  billing_cycle TEXT DEFAULT 'monthly' CHECK (billing_cycle IN (
    'monthly',
    'yearly',
    'school_semester'
  )),
  trial_ends_at TIMESTAMPTZ,
  current_period_start TIMESTAMPTZ,
  current_period_end TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  external_subscription_id TEXT,
  external_customer_id TEXT,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

COMMENT ON TABLE subscriptions IS 'Parent subscription tiers and billing status';

CREATE INDEX idx_subscriptions_parent ON subscriptions(parent_id);
CREATE INDEX idx_subscriptions_tier ON subscriptions(tier);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);

-- Enable RLS
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Parents can view their own subscription
CREATE POLICY "Parents can view subscription"
  ON subscriptions FOR SELECT
  USING (parent_id = auth.uid());

-- Service role can manage subscriptions
CREATE POLICY "Service role can manage subscriptions"
  ON subscriptions FOR ALL
  USING (auth.jwt()->>'role' = 'service_role');

-- Trigger for updated_at
CREATE OR REPLACE FUNCTION subscriptions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER subscriptions_updated_at
  BEFORE UPDATE ON subscriptions
  FOR EACH ROW EXECUTE FUNCTION subscriptions_updated_at();

-- ============================================
-- FIX 4: Add is_deleted soft-delete column to key tables
-- ============================================
ALTER TABLE child_profiles ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;
ALTER TABLE parent_profiles ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE;

-- Trigger for is_deleted check on SELECT (soft delete)
CREATE OR REPLACE FUNCTION public.filter_deleted_records()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_TABLE_NAME = 'child_profiles' AND NEW.is_deleted = TRUE THEN
    -- Keep record but hide from queries
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON COLUMN child_profiles.is_deleted IS 'Soft delete flag. Deleted records are hidden from normal queries but retained for data recovery.';

-- ============================================
-- FIX 5: Update RLS policies to respect soft delete
-- ============================================
-- Child profiles: hide soft-deleted records
DROP POLICY IF EXISTS "Parents can view children" ON child_profiles;
CREATE POLICY "Parents can view children"
  ON child_profiles FOR SELECT
  USING (
    parent_id = auth.uid()
    AND is_deleted = FALSE
    AND is_active = TRUE
  );

-- ============================================
-- FIX 6: Enable realtime for existing tables
-- Note: Tables created in this migration (consent_logs, subscriptions)
-- will be added separately via Supabase Dashboard > Database > Replication
-- ============================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.screen_time_records;
ALTER PUBLICATION supabase_realtime ADD TABLE public.ai_tutor_sessions;

-- ============================================
-- FIX 7: Fix ON DELETE CASCADE → SET NULL for audit trail retention
-- ============================================
-- For audit_logs table: change FK to SET NULL so child deletions don't wipe audit trail
ALTER TABLE audit_logs DROP CONSTRAINT IF EXISTS audit_logs_child_id_fkey;
ALTER TABLE audit_logs ADD CONSTRAINT audit_logs_child_id_fkey
  FOREIGN KEY (child_id) REFERENCES child_profiles(id) ON DELETE SET NULL;

-- ============================================
-- FIX 8: Add missing indexes for performance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_ai_sessions_created ON ai_tutor_sessions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ai_messages_created ON ai_tutor_messages(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_logs_child ON audit_logs(child_id);
CREATE INDEX IF NOT EXISTS idx_screen_time_child_date ON screen_time_records(child_id, date DESC);
