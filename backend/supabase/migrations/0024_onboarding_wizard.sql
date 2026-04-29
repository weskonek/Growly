-- Migration 0024: Onboarding wizard for new parents
-- 6-step guided setup that replaces the "blank dashboard" experience

-- ──────────────────────────────────────────────────────────────────
-- 1. Add onboarding_completed flag to parent_profiles
-- ──────────────────────────────────────────────────────────────────
ALTER TABLE parent_profiles
ADD COLUMN IF NOT EXISTS onboarding_completed BOOLEAN NOT NULL DEFAULT FALSE;

-- ──────────────────────────────────────────────────────────────────
-- 2. Onboarding steps storage (per-step progress, resumable)
-- ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS onboarding_steps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id UUID NOT NULL REFERENCES parent_profiles(id) ON DELETE CASCADE,
  step_number INTEGER NOT NULL CHECK (step_number BETWEEN 1 AND 6),
  completed BOOLEAN NOT NULL DEFAULT FALSE,
  completed_at TIMESTAMPTZ,
  metadata JSONB DEFAULT '{}',
  UNIQUE (parent_id, step_number)
);

-- RLS: parent owns their own onboarding data
ALTER TABLE onboarding_steps ENABLE ROW LEVEL SECURITY;

CREATE POLICY "parents own onboarding steps"
  ON onboarding_steps FOR ALL
  USING (parent_id = auth.uid());

CREATE POLICY "parents read onboarding steps"
  ON onboarding_steps FOR SELECT
  USING (parent_id = auth.uid());

CREATE POLICY "parents insert onboarding steps"
  ON onboarding_steps FOR INSERT
  WITH CHECK (parent_id = auth.uid());

-- Update parent_profiles RLS to allow update of onboarding_completed
-- (Already covered by existing update policy)

-- ──────────────────────────────────────────────────────────────────
-- 3. Seed onboarding step definitions (optional metadata table)
-- ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS onboarding_definitions (
  step_number INTEGER PRIMARY KEY CHECK (step_number BETWEEN 1 AND 6),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  icon_emoji TEXT NOT NULL,
  estimated_minutes INTEGER NOT NULL DEFAULT 1
);

INSERT INTO onboarding_definitions (step_number, title, description, icon_emoji, estimated_minutes)
VALUES
  (1, 'Selamat Datang di Growly',  'Platform pertumbuhan anak berbasis AI yang aman untuk semua usia',                    '👋', 1),
  (2, 'Tambah Anak Pertama',       'Daftar anak Anda untuk mulai memantau dan membimbing aktivitas digital mereka',         '👶', 2),
  (3, 'Atur Waktu Layar',         'Tentukan batasan harian yang sehat agar anak tetap seimbang antara belajar & bermain',   '⏰', 2),
  (4, 'Atur Kontrol Aplikasi',     'Pilih aplikasi mana yang boleh digunakan anak secara bebas',                          '🔒', 2),
  (5, 'Mode Sekolah',             'Aktifkan режим fokus saat jam belajar agar anak tidak terdistraksi',                   '📚', 1),
  (6, 'Siap Memulai!',           'Semua siap! Mulai perjalanan pertumbuhan digital anak Anda bersama Growly',           '🎉', 1)
ON CONFLICT (step_number) DO NOTHING;

COMMENT ON TABLE onboarding_definitions IS 'Static reference data for onboarding step content';