-- Migration 0031: Create notifications table + related infrastructure for FCM push notifications
-- Apply via: Supabase Dashboard SQL Editor or supabase db push

-- ============================================================
-- 1. notifications table — parent-visible notification records
-- ============================================================
CREATE TABLE IF NOT EXISTS public.notifications (
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
CREATE INDEX IF NOT EXISTS idx_notifications_parent_id
    ON public.notifications(parent_id);

CREATE INDEX IF NOT EXISTS idx_notifications_created_at
    ON public.notifications(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_parent_unread
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

DROP TRIGGER IF EXISTS notifications_updated_at ON public.notifications;
CREATE TRIGGER notifications_updated_at
    BEFORE UPDATE ON public.notifications
    FOR EACH ROW EXECUTE FUNCTION public.handle_notification_updated_at();

-- ============================================================
-- 4. RLS policies
-- ============================================================
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Parents can view own notifications" ON public.notifications;
CREATE POLICY "Parents can view own notifications"
    ON public.notifications FOR SELECT
    USING (auth.uid() = parent_id);

DROP POLICY IF EXISTS "Parents can update own notifications" ON public.notifications;
CREATE POLICY "Parents can update own notifications"
    ON public.notifications FOR UPDATE
    USING (auth.uid() = parent_id)
    WITH CHECK (auth.uid() = parent_id);

DROP POLICY IF EXISTS "Service role can manage notifications" ON public.notifications;
CREATE POLICY "Service role can manage notifications"
    ON public.notifications FOR ALL
    USING (auth.jwt()->>'role' = 'service_role')
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

DROP POLICY IF EXISTS "Service role can insert notifications" ON public.notifications;
CREATE POLICY "Service role can insert notifications"
    ON public.notifications FOR INSERT
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

-- ============================================================
-- 5. notification_log table — tracks FCM delivery status
-- ============================================================
CREATE TABLE IF NOT EXISTS public.notification_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_id UUID REFERENCES public.parent_profiles(id) ON DELETE CASCADE,
    notification_id UUID REFERENCES public.notifications(id) ON DELETE SET NULL,
    fcm_sent_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    fcm_status TEXT CHECK (fcm_status IN ('sent', 'failed', 'invalid_token')),
    error_message TEXT
);

CREATE INDEX IF NOT EXISTS idx_notification_log_parent_id
    ON public.notification_log(parent_id);

CREATE INDEX IF NOT EXISTS idx_notification_log_notification_id
    ON public.notification_log(notification_id);

ALTER TABLE public.notification_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Service role can manage notification_log" ON public.notification_log;
CREATE POLICY "Service role can manage notification_log"
    ON public.notification_log FOR ALL
    USING (auth.jwt()->>'role' = 'service_role')
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

-- ============================================================
-- 6. Add fcm_token to parent_profiles (for FCM push delivery)
-- ============================================================
ALTER TABLE public.parent_profiles
    ADD COLUMN IF NOT EXISTS fcm_token TEXT,
    ADD COLUMN IF NOT EXISTS fcm_token_updated_at TIMESTAMPTZ;

DROP POLICY IF EXISTS "Parents can update own fcm_token" ON public.parent_profiles;
CREATE POLICY "Parents can update own fcm_token"
    ON public.parent_profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);