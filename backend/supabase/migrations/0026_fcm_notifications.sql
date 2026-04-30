-- Migration 0026: Push Notifications (FCM) Setup
-- Adds fcm_token column to parent_profiles + notification_log for sent FCM history

-- 1. Add FCM token to parent_profiles
ALTER TABLE parent_profiles
ADD COLUMN IF NOT EXISTS fcm_token TEXT,
ADD COLUMN IF NOT EXISTS fcm_token_updated_at TIMESTAMPTZ;

-- 2. Notification log table — records every FCM push sent
CREATE TABLE IF NOT EXISTS notification_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID NOT NULL REFERENCES parent_profiles(id) ON DELETE CASCADE,
  notification_id UUID NOT NULL REFERENCES notifications(id) ON DELETE CASCADE,
  fcm_sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  fcm_status TEXT,  -- 'sent', 'failed', 'invalid_token'
  error_message TEXT
);

-- Index for querying a parent's notification history
CREATE INDEX IF NOT EXISTS idx_notification_log_parent_id ON notification_log(parent_id);
CREATE INDEX IF NOT EXISTS idx_notification_log_created_at ON notification_log(fcm_sent_at DESC);

-- RLS: parents can only see their own notification logs
ALTER TABLE notification_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Parents can view own notification logs"
  ON notification_log FOR SELECT
  USING (auth.uid() = parent_id);

CREATE POLICY "Service role can insert notification logs"
  ON notification_log FOR INSERT
  WITH CHECK (true);

-- 3. Allow parent app service to update fcm_token on parent_profiles
ALTER TABLE parent_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Parents can update own fcm_token"
  ON parent_profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- 4. Cron job: cleanup old notification_log entries (keep 30 days)
-- Handled via Supabase cron or pg_cron extension if available