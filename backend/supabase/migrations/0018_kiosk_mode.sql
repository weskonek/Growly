-- Add kiosk_app_package column for Kiosk Mode
ALTER TABLE child_profiles
ADD COLUMN IF NOT EXISTS kiosk_app_package TEXT;

COMMENT ON COLUMN child_profiles.kiosk_app_package IS 'Package name of the single locked-down app in Kiosk Mode';
