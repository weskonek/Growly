-- Migration: 0029_onboarding_screen_time_school_tables
-- Creates screen_time_rules table + RLS policies for onboarding wizard

CREATE TABLE IF NOT EXISTS public.screen_time_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    child_id UUID NOT NULL REFERENCES public.child_profiles(id) ON DELETE CASCADE UNIQUE,
    daily_limit_minutes INTEGER NOT NULL DEFAULT 120,
    bedtime_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    bedtime_start TIME DEFAULT '20:00',
    bedtime_end TIME DEFAULT '07:00',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ
);

ALTER TABLE public.screen_time_rules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Parents can insert screen_time_rules"
  ON public.screen_time_rules FOR INSERT
  WITH CHECK (auth.uid() = (SELECT parent_id FROM public.child_profiles WHERE id = child_profiles.id));

CREATE POLICY "Parents can view screen_time_rules"
  ON public.screen_time_rules FOR SELECT
  USING (auth.uid() = (SELECT parent_id FROM public.child_profiles WHERE id = child_profiles.id));

CREATE POLICY "Parents can update screen_time_rules"
  ON public.screen_time_rules FOR UPDATE
  USING (auth.uid() = (SELECT parent_id FROM public.child_profiles WHERE id = child_profiles.id));

-- RLS policies for schedules (school mode)
CREATE POLICY "Parents can insert schedules"
  ON public.schedules FOR INSERT
  WITH CHECK (auth.uid() = (SELECT parent_id FROM public.child_profiles WHERE id = child_profiles.id));

CREATE POLICY "Parents can select schedules"
  ON public.schedules FOR SELECT
  USING (auth.uid() = (SELECT parent_id FROM public.child_profiles WHERE id = child_profiles.id));

CREATE POLICY "Parents can update schedules"
  ON public.schedules FOR UPDATE
  USING (auth.uid() = (SELECT parent_id FROM public.child_profiles WHERE id = child_profiles.id));

-- RLS policies for app_restrictions (app lock step)
CREATE POLICY "Parents can insert app_restrictions"
  ON public.app_restrictions FOR INSERT
  WITH CHECK (auth.uid() = (SELECT parent_id FROM public.child_profiles WHERE id = child_profiles.id));

CREATE POLICY "Parents can select app_restrictions"
  ON public.app_restrictions FOR SELECT
  USING (auth.uid() = (SELECT parent_id FROM public.child_profiles WHERE id = child_profiles.id));

CREATE POLICY "Parents can update app_restrictions"
  ON public.app_restrictions FOR UPDATE
  USING (auth.uid() = (SELECT parent_id FROM public.child_profiles WHERE id = child_profiles.id));
