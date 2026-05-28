-- Migration 0031: Create notifications table + fix notification_log FK
-- Required FK reference from migration 0026 which creates notification_log
-- that references notifications(id) ON DELETE CASCADE — but notifications table was never created.

-- ============================================================
-- 1. notifications table — parent-visible notification records
-- ============================================================
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID NOT NULL REFERENCES public.parent_profiles(id) ON DELETE CASCADE,
    child_id UUID REFERENCES public.child_profiles(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT NOT NULL DEFAULT 'general',
    -- 'achievement' | 'screen_time_alert' | 'subscription_reminder' | 'daily_report' | 'general'
    deep_link TEXT,
    metadata JSONB DEFAULT '{}',
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    is_sent BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- ============================================================
-- 2. Indexes for query performance
-- ============================================================
CREATE INDEX idx_notifications_parent_id
    ON public.notifications(parent_id);

CREATE INDEX idx_notifications_created_at
    ON public.notifications(created_at DESC);

CREATE INDEX idx_notifications_parent_unread
    ON public.notifications(parent_id, is_read)
    WHERE is_read = FALSE;

-- ============================================================
-- 3. Trigger to auto-update updated_at
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_notification_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER notifications_updated_at
    BEFORE UPDATE ON public.notifications
    FOR EACH ROW EXECUTE FUNCTION public.handle_notification_updated_at();

-- ============================================================
-- 4. RLS policies
-- ============================================================
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Parents can only SELECT their own notifications
CREATE POLICY "Parents can view own notifications"
    ON public.notifications FOR SELECT
    USING (auth.uid() = parent_id);

-- Parents can UPDATE (mark as read) their own notifications
CREATE POLICY "Parents can update own notifications"
    ON public.notifications FOR UPDATE
    USING (auth.uid() = parent_id)
    WITH CHECK (auth.uid() = parent_id);

-- Service role can do everything (used by edge functions)
CREATE POLICY "Service role can manage notifications"
    ON public.notifications FOR ALL
    USING (auth.jwt()->>'role' = 'service_role')
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

-- Anonymous/anon key can INSERT (admin sends on behalf of parent)
-- Edge function is the actual gatekeeper; this policy enables service
-- role client via anon key + service role bypass in edge function.
CREATE POLICY "Service role can insert notifications"
    ON public.notifications FOR INSERT
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

-- ============================================================
-- 5. Fix notification_log FK → make notification_id nullable
--    The FK references notifications(id) but that table didn't exist.
--    edge function inserts notification_log independently so we
--    cannot enforce the FK without transactions spanning both tables.
-- ============================================================
ALTER TABLE notification_log
    DROP CONSTRAINT IF EXISTS notification_log_notification_id_fkey;

ALTER TABLE notification_log
    ALTER COLUMN notification_id DROP NOT NULL;

-- ============================================================
-- 6. Fix any pre-existing rows with orphaned notification_id values
-- (graceful: set them to NULL rather than failing)
-- ============================================================
UPDATE notification_log
SET notification_id = NULL
WHERE notification_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM notifications WHERE notifications.id = notification_log.notification_id);

-- Add a check constraint to ensure we never have orphaned FKs going forward
ALTER TABLE notification_log
    ADD CONSTRAINT notification_log_notification_id_exists
    CHECK (
        notification_id IS NULL
        OR EXISTS (SELECT 1 FROM notifications WHERE notifications.id = notification_log.notification_id)
    );
