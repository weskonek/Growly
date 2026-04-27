-- Growly Realtime Configuration Migration
-- Enables Supabase Realtime for cross-device sync

-- ============================================
-- ENABLE REALTIME ON DATABASE LEVEL
-- ============================================
ALTER DATABASE supabase_db SET app.settings.realtime.enabled = true;

-- ============================================
-- ADD TABLES TO REALTIME PUBLICATION
-- ============================================
-- These tables will broadcast changes to connected clients

-- Child profiles - for profile updates across devices
ALTER PUBLICATION supabase_realtime ADD TABLE public.child_profiles;

-- Learning progress - for real-time progress updates
ALTER PUBLICATION supabase_realtime ADD TABLE public.learning_progress;

-- Learning sessions - for session tracking
ALTER PUBLICATION supabase_realtime ADD TABLE public.learning_sessions;

-- Schedules - for schedule sync from parent to child
ALTER PUBLICATION supabase_realtime ADD TABLE public.schedules;

-- App restrictions - for restriction sync
ALTER PUBLICATION supabase_realtime ADD TABLE public.app_restrictions;

-- Badges - for real-time badge notifications
ALTER PUBLICATION supabase_realtime ADD TABLE public.badges;

-- Reward systems - for streak/stars updates
ALTER PUBLICATION supabase_realtime ADD TABLE public.reward_systems;

-- ============================================
-- REALTIME FILTERS (optional per-table config)
-- ============================================
-- Note: Supabase Realtime broadcasts all changes by default
-- For more granular control, use Postgres filters in the client

-- ============================================
-- HELPER FUNCTIONS FOR REALTIME
-- ============================================

-- Function to broadcast child profile update
CREATE OR REPLACE FUNCTION public.broadcast_child_update()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify(
        'child_updates',
        json_build_object(
            'operation', TG_OP,
            'table', 'child_profiles',
            'id', NEW.id,
            'parent_id', NEW.parent_id
        )::text
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for real-time child profile updates
CREATE TRIGGER child_profiles_realtime_notify
    AFTER UPDATE ON public.child_profiles
    FOR EACH ROW EXECUTE FUNCTION public.broadcast_child_update();

-- Function to broadcast schedule changes
CREATE OR REPLACE FUNCTION public.broadcast_schedule_update()
RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify(
        'schedule_updates',
        json_build_object(
            'operation', TG_op,
            'table', 'schedules',
            'id', NEW.id,
            'child_id', NEW.child_id
        )::text
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER schedules_realtime_notify
    AFTER INSERT OR UPDATE OR DELETE ON public.schedules
    FOR EACH ROW EXECUTE FUNCTION public.broadcast_schedule_update();

-- ============================================
-- DATABASE LISTENERS (for Edge Functions)
-- ============================================

-- Enable LISTEN/NOTIFY for edge functions
-- This is used by Edge Functions to listen for database changes

-- Note: Supabase manages this internally, but this migration
-- ensures the channels are properly configured

-- ============================================
-- REALTIME PRESENCE (for multi-device sync)
-- ============================================
-- Presence allows tracking which devices are connected
-- This is useful for "last active" status and online indicators

-- ============================================
-- NOTES FOR CLIENT IMPLEMENTATION
-- ============================================
/*
Flutter client usage:

// Subscribe to child profile changes
supabase
  .channel('child-profile-${childId}')
  .onPostgresChanges(
    event: PostgresChangeEvent.update,
    schema: 'public',
    table: 'child_profiles',
    filter: Filter.eq('id', childId),
    callback: (payload) {
      // Update local state with new data
    }
  )
  .subscribe();

// Subscribe to schedule changes
supabase
  .channel('schedules-${childId}')
  .onPostgresChanges(
    event: PostgresChangeEvent.all,
    schema: 'public',
    table: 'schedules',
    filter: Filter.eq('child_id', childId),
    callback: (payload) {
      // Update screen time mode
    }
  )
  .subscribe();

// Unsubscribe when no longer needed
supabase.removeChannel(channel);
*/

-- ============================================
-- BACKWARDS COMPATIBILITY CHECKS
-- ============================================
-- Ensure realtime is enabled in supabase/config.toml:
/*
[realtime]
enabled = true
ip_version = "ipv4"
*/
-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- Run these to verify realtime is configured:

-- Check enabled tables:
-- SELECT * FROM pg_publication_tables WHERE pubname = 'supabase_realtime';

-- Check trigger exists:
-- SELECT tgname FROM pg_trigger WHERE tgname LIKE '%_realtime_notify';