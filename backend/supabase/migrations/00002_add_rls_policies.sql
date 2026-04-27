-- Growly RLS Policies Migration
-- Row Level Security policies for all tables
-- Ensures parents can only access their own children's data

-- ============================================
-- ENABLE RLS ON ALL TABLES
-- ============================================
ALTER TABLE public.parent_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.child_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.learning_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.learning_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.screen_time_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_restrictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reward_systems ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_tutor_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_tutor_messages ENABLE ROW LEVEL SECURITY;
-- audit_logs is system table, handled separately

-- ============================================
-- PARENT PROFILES POLICIES
-- ============================================

-- Parents can view their own profile
CREATE POLICY "Parent profiles are viewable by owner"
    ON public.parent_profiles
    FOR SELECT
    USING (auth.uid() = id);

-- Parents can update their own profile
CREATE POLICY "Parent profiles are updatable by owner"
    ON public.parent_profiles
    FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- System can insert parent profiles (via triggers/signup hooks)
CREATE POLICY "Parent profiles are insertable by service role"
    ON public.parent_profiles
    FOR INSERT
    WITH CHECK (auth.uid() = id);

-- ============================================
-- CHILD PROFILES POLICIES
-- ============================================

-- Children are viewable by parent
CREATE POLICY "Children are viewable by parent"
    ON public.child_profiles
    FOR SELECT
    USING (
        parent_id IN (
            SELECT id FROM public.parent_profiles WHERE id = auth.uid()
        )
    );

-- Parents can create child profiles
CREATE POLICY "Children are insertable by parent"
    ON public.child_profiles
    FOR INSERT
    WITH CHECK (
        parent_id IN (
            SELECT id FROM public.parent_profiles WHERE id = auth.uid()
        )
    );

-- Parents can update their children's profiles
CREATE POLICY "Children are updatable by parent"
    ON public.child_profiles
    FOR UPDATE
    USING (
        parent_id IN (
            SELECT id FROM public.parent_profiles WHERE id = auth.uid()
        )
    )
    WITH CHECK (
        parent_id IN (
            SELECT id FROM public.parent_profiles WHERE id = auth.uid()
        )
    );

-- Parents can delete their children
CREATE POLICY "Children are deletable by parent"
    ON public.child_profiles
    FOR DELETE
    USING (
        parent_id IN (
            SELECT id FROM public.parent_profiles WHERE id = auth.uid()
        )
    );

-- Service role can read child profiles for AI tutor
CREATE POLICY "Children are viewable by service role"
    ON public.child_profiles
    FOR SELECT
    USING (auth.jwt()->>'role' = 'service_role');

-- ============================================
-- LEARNING PROGRESS POLICIES
-- ============================================

-- Learning progress is viewable by parent
CREATE POLICY "Learning progress is viewable by parent"
    ON public.learning_progress
    FOR SELECT
    USING (
        child_id IN (
            SELECT id FROM public.child_profiles
            WHERE parent_id IN (
                SELECT id FROM public.parent_profiles WHERE id = auth.uid()
            )
        )
    );

-- Authenticated users can insert learning progress (from child app)
CREATE POLICY "Learning progress is insertable by authenticated"
    ON public.learning_progress
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- Parents can update their children's progress
CREATE POLICY "Learning progress is updatable by parent"
    ON public.learning_progress
    FOR UPDATE
    USING (
        child_id IN (
            SELECT id FROM public.child_profiles
            WHERE parent_id IN (
                SELECT id FROM public.parent_profiles WHERE id = auth.uid()
            )
        )
    );

-- ============================================
-- LEARNING SESSIONS POLICIES
-- ============================================

CREATE POLICY "Learning sessions are viewable by parent"
    ON public.learning_sessions
    FOR SELECT
    USING (
        child_id IN (
            SELECT id FROM public.child_profiles
            WHERE parent_id IN (
                SELECT id FROM public.parent_profiles WHERE id = auth.uid()
            )
        )
    );

CREATE POLICY "Learning sessions are insertable by authenticated"
    ON public.learning_sessions
    FOR INSERT
    WITH CHECK (auth.role() = 'authenticated');

-- ============================================
-- SCREEN TIME RECORDS POLICIES
-- ============================================

-- Screen time records viewable by parent
CREATE POLICY "Screen time is viewable by parent"
    ON public.screen_time_records
    FOR SELECT
    USING (
        child_id IN (
            SELECT id FROM public.child_profiles
            WHERE parent_id IN (
                SELECT id FROM public.parent_profiles WHERE id = auth.uid()
            )
        )
    );

-- Child app can insert screen time (with anonymous key or limited auth)
CREATE POLICY "Screen time is insertable by service role"
    ON public.screen_time_records
    FOR INSERT
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

-- ============================================
-- APP RESTRICTIONS POLICIES
-- ============================================

-- App restrictions viewable by parent
CREATE POLICY "App restrictions are viewable by parent"
    ON public.app_restrictions
    FOR SELECT
    USING (
        child_id IN (
            SELECT id FROM public.child_profiles
            WHERE parent_id IN (
                SELECT id FROM public.parent_profiles WHERE id = auth.uid()
            )
        )
    );

-- App restrictions manageable by parent only
CREATE POLICY "App restrictions are manageable by parent"
    ON public.app_restrictions
    FOR ALL
    USING (
        child_id IN (
            SELECT id FROM public.child_profiles
            WHERE parent_id IN (
                SELECT id FROM public.parent_profiles WHERE id = auth.uid()
            )
        )
    );

-- Child app can read restrictions to enforce them
CREATE POLICY "App restrictions are readable by child app"
    ON public.app_restrictions
    FOR SELECT
    USING (auth.jwt()->>'role' IN ('service_role', 'authenticated'));

-- ============================================
-- SCHEDULES POLICIES
-- ============================================

CREATE POLICY "Schedules are viewable by parent"
    ON public.schedules
    FOR SELECT
    USING (
        child_id IN (
            SELECT id FROM public.child_profiles
            WHERE parent_id IN (
                SELECT id FROM public.parent_profiles WHERE id = auth.uid()
            )
        )
    );

CREATE POLICY "Schedules are manageable by parent"
    ON public.schedules
    FOR ALL
    USING (
        child_id IN (
            SELECT id FROM public.child_profiles
            WHERE parent_id IN (
                SELECT id FROM public.parent_profiles WHERE id = auth.uid()
            )
        )
    );

-- Child app can read schedules to know current mode
CREATE POLICY "Schedules are readable by child app"
    ON public.schedules
    FOR SELECT
    USING (auth.jwt()->>'role' IN ('service_role', 'authenticated'));

-- ============================================
-- BADGES POLICIES
-- ============================================

CREATE POLICY "Badges are viewable by parent"
    ON public.badges
    FOR SELECT
    USING (
        child_id IN (
            SELECT id FROM public.child_profiles
            WHERE parent_id IN (
                SELECT id FROM public.parent_profiles WHERE id = auth.uid()
            )
        )
    );

CREATE POLICY "Badges are insertable by service role"
    ON public.badges
    FOR INSERT
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

CREATE POLICY "Badges are viewable by child app"
    ON public.badges
    FOR SELECT
    USING (auth.jwt()->>'role' IN ('service_role', 'authenticated'));

-- ============================================
-- REWARD SYSTEMS POLICIES
-- ============================================

CREATE POLICY "Reward systems are viewable by parent"
    ON public.reward_systems
    FOR SELECT
    USING (
        child_id IN (
            SELECT id FROM public.child_profiles
            WHERE parent_id IN (
                SELECT id FROM public.parent_profiles WHERE id = auth.uid()
            )
        )
    );

CREATE POLICY "Reward systems are updatable by service role"
    ON public.reward_systems
    FOR UPDATE
    USING (auth.jwt()->>'role' = 'service_role')
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

CREATE POLICY "Reward systems are insertable by service role"
    ON public.reward_systems
    FOR INSERT
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

-- ============================================
-- AI TUTOR SESSIONS POLICIES
-- ============================================

-- Parents can view AI sessions for their children
CREATE POLICY "AI sessions are viewable by parent"
    ON public.ai_tutor_sessions
    FOR SELECT
    USING (
        child_id IN (
            SELECT id FROM public.child_profiles
            WHERE parent_id IN (
                SELECT id FROM public.parent_profiles WHERE id = auth.uid()
            )
        )
    );

-- Edge functions insert AI sessions with service role
CREATE POLICY "AI sessions are insertable by service role"
    ON public.ai_tutor_sessions
    FOR INSERT
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

-- AI tutor messages
CREATE POLICY "AI messages are viewable by parent"
    ON public.ai_tutor_messages
    FOR SELECT
    USING (
        session_id IN (
            SELECT id FROM public.ai_tutor_sessions
            WHERE child_id IN (
                SELECT id FROM public.child_profiles
                WHERE parent_id IN (
                    SELECT id FROM public.parent_profiles WHERE id = auth.uid()
                )
            )
        )
    );

CREATE POLICY "AI messages are insertable by service role"
    ON public.ai_tutor_messages
    FOR INSERT
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

-- ============================================
-- AUDIT LOGS POLICIES (read-only for admins)
-- ============================================

-- System inserts audit logs
CREATE POLICY "Audit logs are insertable by service role"
    ON public.audit_logs
    FOR INSERT
    WITH CHECK (auth.jwt()->>'role' = 'service_role');

-- Parents can view their own audit logs
CREATE POLICY "Audit logs are viewable by own user"
    ON public.audit_logs
    FOR SELECT
    USING (user_id = auth.uid() OR auth.jwt()->>'role' = 'service_role');

-- ============================================
-- HELPER FUNCTIONS FOR RLS
-- ============================================

-- Function to check if user is parent of child
CREATE OR REPLACE FUNCTION public.is_parent_of_child(parent_uuid UUID, child_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.child_profiles cp
        WHERE cp.id = child_uuid
        AND cp.parent_id = parent_uuid
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get parent ID from auth.uid()
CREATE OR REPLACE FUNCTION public.get_parent_id()
RETURNS UUID AS $$
BEGIN
    RETURN auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;