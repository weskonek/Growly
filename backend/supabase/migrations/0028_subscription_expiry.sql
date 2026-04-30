-- Migration 0028: Subscription Expiry Auto-Downgrade + Reminders
-- Auto-downgrade expired subscriptions to free tier
-- Send H-7 reminder notifications for expiring subscriptions
--
-- To schedule these to run daily, enable pg_cron in Supabase:
--   CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA pg_catalog;
--
-- Then schedule via SQL editor:
--   SELECT cron.schedule('daily-subscription-check', '0 8 * * *',
--     $$ SELECT downgrade_expired_subscriptions(); SELECT send_expiry_reminder_notifications(); $$
--   );

-- 1. Auto-downgrade expired subscriptions to free tier
CREATE OR REPLACE FUNCTION downgrade_expired_subscriptions()
RETURNS void AS $$
BEGIN
  UPDATE subscriptions
  SET status = 'expired', cancelled_at = NOW()
  WHERE status = 'active'
    AND current_period_end < NOW()
    AND tier != 'free';

  UPDATE subscriptions
  SET tier = 'free'
  WHERE status = 'expired'
    AND tier != 'free';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Send H-7 reminder notifications for expiring subscriptions
CREATE OR REPLACE FUNCTION send_expiry_reminder_notifications()
RETURNS void AS $$
DECLARE
  rec RECORD;
BEGIN
  FOR rec IN
    SELECT s.parent_id, s.tier
    FROM subscriptions s
    WHERE s.status = 'active'
      AND s.tier != 'free'
      AND s.current_period_end > NOW()
      AND s.current_period_end <= NOW() + INTERVAL '7 days'
  LOOP
    IF NOT EXISTS (
      SELECT 1 FROM notifications
      WHERE parent_id = rec.parent_id
        AND type = 'subscription_reminder'
        AND created_at > NOW() - INTERVAL '7 days'
    ) THEN
      INSERT INTO notifications (parent_id, title, body, type)
      VALUES (
        rec.parent_id,
        '⏰ Langganan Akan Berakhir',
        'Langganan ' || rec.tier || ' akan berakhir dalam 7 hari. Perpanjang sekarang!',
        'subscription_reminder'
      );
    END IF;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Allow service_role to call these functions
GRANT EXECUTE ON FUNCTION downgrade_expired_subscriptions() TO service_role;
GRANT EXECUTE ON FUNCTION send_expiry_reminder_notifications() TO service_role;