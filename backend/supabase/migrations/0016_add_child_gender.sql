-- Add gender column to child_profiles for analytics/reporting
ALTER TABLE public.child_profiles
    ADD COLUMN IF NOT EXISTS gender TEXT CHECK (gender IN ('male', 'female', 'other'));

COMMENT ON COLUMN public.child_profiles.gender IS 'Gender: male, female, or other (optional)';