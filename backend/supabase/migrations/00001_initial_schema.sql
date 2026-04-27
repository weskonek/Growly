-- Growly Initial Schema Migration
-- Creates all core tables for the Growly AI-powered digital growth platform
-- MVP Focus: Ages 4-9

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- PARENT PROFILES (extends Supabase Auth)
-- ============================================
CREATE TABLE public.parent_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    avatar_url TEXT,
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    last_login_at TIMESTAMPTZ
);

-- ============================================
-- CHILD PROFILES
-- ============================================
CREATE TABLE public.child_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    parent_id UUID NOT NULL REFERENCES public.parent_profiles(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    birth_date DATE NOT NULL,
    avatar_url TEXT,
    -- Age group: 0=earlyChildhood(2-5), 1=primary(6-9), 2=upperPrimary(10-12), 3=teen(13-18)
    age_group INTEGER NOT NULL CHECK (age_group BETWEEN 0 AND 3),
    -- Hashed PIN for child app access (4-6 digits)
    pin_hash TEXT,
    settings JSONB DEFAULT '{}',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- ============================================
-- LEARNING PROGRESS
-- ============================================
CREATE TABLE public.learning_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES public.child_profiles(id) ON DELETE CASCADE,
    subject TEXT NOT NULL, -- reading, math, science, creative, language
    topic TEXT NOT NULL,
    score INTEGER DEFAULT 0 CHECK (score >= 0 AND score <= 100),
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    session_id UUID,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- ============================================
-- LEARNING SESSIONS
-- ============================================
CREATE TABLE public.learning_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES public.child_profiles(id) ON DELETE CASCADE,
    subject TEXT NOT NULL,
    started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMPTZ,
    duration_minutes INTEGER DEFAULT 0,
    topics_covered TEXT[] DEFAULT '{}',
    session_type TEXT DEFAULT 'free_play', -- ai_tutor, learning_hub, game
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- SCREEN TIME RECORDS
-- ============================================
CREATE TABLE public.screen_time_records (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES public.child_profiles(id) ON DELETE CASCADE,
    app_package TEXT NOT NULL,
    app_name TEXT,
    duration_minutes INTEGER NOT NULL DEFAULT 0,
    date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- APP RESTRICTIONS (whitelist/blacklist)
-- ============================================
CREATE TABLE public.app_restrictions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES public.child_profiles(id) ON DELETE CASCADE,
    app_package TEXT NOT NULL,
    app_name TEXT,
    app_icon TEXT,
    is_allowed BOOLEAN NOT NULL DEFAULT TRUE,
    time_limit_minutes INTEGER,
    daily_limit_used INTEGER DEFAULT 0,
    schedule_limits JSONB DEFAULT '{}', -- {"monday": 60, "tuesday": 60}
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ,
    UNIQUE(child_id, app_package)
);

-- ============================================
-- SCHEDULES (time-based mode switching)
-- ============================================
CREATE TABLE public.schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES public.child_profiles(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    mode TEXT NOT NULL CHECK (mode IN ('normal', 'learning', 'school', 'sleep', 'break')),
    is_enabled BOOLEAN DEFAULT TRUE,
    label TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- ============================================
-- BADGES
-- ============================================
CREATE TABLE public.badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES public.child_profiles(id) ON DELETE CASCADE,
    badge_type INTEGER NOT NULL, -- 0=streak, 1=topicMaster, 2=dailyGoal, etc.
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    emoji TEXT NOT NULL,
    earned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    metadata JSONB DEFAULT '{}'
);

-- ============================================
-- REWARD SYSTEMS
-- ============================================
CREATE TABLE public.reward_systems (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID UNIQUE NOT NULL REFERENCES public.child_profiles(id) ON DELETE CASCADE,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    total_stars INTEGER DEFAULT 0,
    unlocked_badges TEXT[] DEFAULT '{}',
    last_activity_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

-- ============================================
-- AI TUTOR SESSIONS (analytics & safety)
-- ============================================
CREATE TABLE public.ai_tutor_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES public.child_profiles(id) ON DELETE CASCADE,
    mode TEXT NOT NULL, -- story, math, homework, general
    prompt TEXT NOT NULL,
    response TEXT,
    response_time_ms INTEGER,
    tokens_used INTEGER,
    flagged BOOLEAN DEFAULT FALSE,
    flag_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- AI TUTOR CONVERSATIONS (per session)
-- ============================================
CREATE TABLE public.ai_tutor_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES public.ai_tutor_sessions(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- AUDIT LOGS (COPPA compliance)
-- ============================================
CREATE TABLE public.audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id),
    child_id UUID REFERENCES public.child_profiles(id),
    action TEXT NOT NULL,
    table_name TEXT,
    record_id UUID,
    old_data JSONB,
    new_data JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- INDEXES
-- ============================================
CREATE INDEX idx_child_profiles_parent ON public.child_profiles(parent_id);
CREATE INDEX idx_child_profiles_age_group ON public.child_profiles(age_group);
CREATE INDEX idx_learning_progress_child ON public.learning_progress(child_id);
CREATE INDEX idx_learning_progress_subject ON public.learning_progress(subject);
CREATE INDEX idx_learning_sessions_child ON public.learning_sessions(child_id);
CREATE INDEX idx_screen_time_child_date ON public.screen_time_records(child_id, date);
CREATE INDEX idx_screen_time_date ON public.screen_time_records(date);
CREATE INDEX idx_app_restrictions_child ON public.app_restrictions(child_id);
CREATE INDEX idx_schedules_child ON public.schedules(child_id);
CREATE INDEX idx_schedules_day ON public.schedules(day_of_week);
CREATE INDEX idx_badges_child ON public.badges(child_id);
CREATE INDEX idx_ai_sessions_child ON public.ai_tutor_sessions(child_id);
CREATE INDEX idx_ai_sessions_flagged ON public.ai_tutor_sessions(flagged) WHERE flagged = TRUE;
CREATE INDEX idx_ai_messages_session ON public.ai_tutor_messages(session_id);
CREATE INDEX idx_audit_logs_user ON public.audit_logs(user_id);
CREATE INDEX idx_audit_logs_created ON public.audit_logs(created_at);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for parent_profiles
CREATE TRIGGER parent_profiles_updated_at
    BEFORE UPDATE ON public.parent_profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Trigger for child_profiles
CREATE TRIGGER child_profiles_updated_at
    BEFORE UPDATE ON public.child_profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Trigger for learning_progress
CREATE TRIGGER learning_progress_updated_at
    BEFORE UPDATE ON public.learning_progress
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Trigger for app_restrictions
CREATE TRIGGER app_restrictions_updated_at
    BEFORE UPDATE ON public.app_restrictions
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Trigger for schedules
CREATE TRIGGER schedules_updated_at
    BEFORE UPDATE ON public.schedules
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Trigger for reward_systems
CREATE TRIGGER reward_systems_updated_at
    BEFORE UPDATE ON public.reward_systems
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Function to calculate age from birth_date
CREATE OR REPLACE FUNCTION public.get_child_age(birth_date DATE)
RETURNS INTEGER AS $$
BEGIN
    RETURN EXTRACT(YEAR FROM AGE(birth_date))::INTEGER;
END;
$$ LANGUAGE plpgsql;

-- Function to get current schedule for a child
CREATE OR REPLACE FUNCTION public.get_current_schedule(child_id_param UUID)
RETURNS TABLE(
    id UUID,
    mode TEXT,
    label TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT s.id, s.mode, s.label
    FROM public.schedules s
    WHERE s.child_id = child_id_param
      AND s.is_enabled = TRUE
      AND s.day_of_week = EXTRACT(DOW FROM NOW())::INTEGER + 1
      AND CURRENT_TIME BETWEEN s.start_time AND s.end_time
    LIMIT 1;
END;
$$ LANGUAGE plpgsql;

-- Function to log audit trail
CREATE OR REPLACE FUNCTION public.log_audit(
    action_param TEXT,
    table_param TEXT,
    record_id_param UUID,
    old_data_param JSONB,
    new_data_param JSONB
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO public.audit_logs (action, table_name, record_id, old_data, new_data)
    VALUES (action_param, table_param, record_id_param, old_data_param, new_data_param);
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- SEED DATA (optional initial data)
-- ============================================
-- Seed data will be in separate seed.sql file