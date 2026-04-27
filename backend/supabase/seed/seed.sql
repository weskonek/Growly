-- Growly Seed Data
-- IMPORTANT: Run this AFTER all migrations are applied!
-- This file sets up badge templates and helper functions

-- ============================================
-- CHECK: Verify tables exist first
-- ============================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'badges') THEN
        RAISE NOTICE 'Tables not yet created. Run migrations first: supabase db push';
    ELSE
        RAISE NOTICE 'Tables verified. Applying seed data...';
    END IF;
END $$;

-- ============================================
-- HELPER FUNCTIONS FOR BADGES
-- (These reference tables, so run after migrations)
-- ============================================

-- Function to award badge to child
CREATE OR REPLACE FUNCTION public.award_badge(
    p_child_id UUID,
    p_badge_type INTEGER,
    p_name TEXT,
    p_description TEXT,
    p_emoji TEXT
)
RETURNS UUID AS $$
DECLARE
    v_badge_id UUID;
BEGIN
    -- Check if badge already exists
    IF EXISTS (
        SELECT 1 FROM public.badges
        WHERE child_id = p_child_id AND badge_type = p_badge_type
    ) THEN
        RETURN NULL;
    END IF;

    INSERT INTO public.badges (id, child_id, badge_type, name, description, emoji)
    VALUES (uuid_generate_v4(), p_child_id, p_badge_type, p_name, p_description, p_emoji)
    RETURNING id INTO v_badge_id;

    UPDATE public.reward_systems
    SET unlocked_badges = array_append(unlocked_badges, p_emoji)
    WHERE child_id = p_child_id;

    RETURN v_badge_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to initialize reward system for child
CREATE OR REPLACE FUNCTION public.init_reward_system(p_child_id UUID)
RETURNS VOID AS $$
BEGIN
    INSERT INTO public.reward_systems (id, child_id, current_streak, longest_streak, total_stars)
    VALUES (uuid_generate_v4(), p_child_id, 0, 0, 0)
    ON CONFLICT (child_id) DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- TRIGGER: Auto-init reward system on child creation
-- ============================================
DROP TRIGGER IF EXISTS on_child_created ON public.child_profiles;

CREATE TRIGGER on_child_created
    AFTER INSERT ON public.child_profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_child();

-- ============================================
-- DEFAULT BADGES FOR NEW CHILDREN
-- (Inserted via app when badge is earned)
-- ============================================
-- Badge types:
-- 0: streak - Belajar连续
-- 1: topicMaster - Master topik
-- 2: dailyGoal - Target harian
-- 3: weeklyGoal - Target mingguan
-- 4: learningHours - Total jam belajar
-- 5: perfectScore - Skor sempurna
-- 6: consistent - Konsisten
-- 7: explorer - Penjelajah

-- ============================================
-- NOTES
-- ============================================
-- Run order:
-- 1. supabase db push (applies all migrations)
-- 2. psql $DATABASE_URL -f seed.sql
--
-- Or via Supabase Dashboard:
-- SQL Editor > Run seed.sql after migrations
