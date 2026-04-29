-- Growly Store: cosmetic items purchasable with stars

CREATE TABLE IF NOT EXISTS store_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  price_stars INTEGER NOT NULL CHECK (price_stars > 0),
  category TEXT NOT NULL CHECK (category IN ('avatar', 'profile', 'badge', 'premium')),
  emoji TEXT,
  image_url TEXT,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Track which items each child has purchased
CREATE TABLE IF NOT EXISTS child_store_purchases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id UUID NOT NULL REFERENCES child_profiles(id) ON DELETE CASCADE,
  item_id UUID NOT NULL REFERENCES store_items(id) ON DELETE CASCADE,
  purchased_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  stars_spent INTEGER NOT NULL,
  UNIQUE (child_id, item_id)
);

-- Seed store items
INSERT INTO store_items (name, description, price_stars, category, emoji)
VALUES
  -- Avatar cosmetics
  ('Topi Petani',    'Topi keren untuk avatar',           30, 'avatar', '🎩'),
  ('Kacamata Anak',   'Kacamata estilos untuk avatar',     40, 'avatar', '😎'),
  ('Sayap Malaikat',  'Sayap cantik untuk avatar',         80, 'avatar', '👼'),
  ('Mahkota Raja',    'Mahkota keemasan untuk avatar',    100, 'avatar', '👑'),
  ('Helm Astronaut',  'Helm antariksa untuk avatar',       60, 'avatar', '🚀'),
  ('Baju Koboi',      'Baju koboi keren untuk avatar',     35, 'avatar', '🤠'),
  ('Gaun Princess',   'Gaun princess untuk avatar',         50, 'avatar', '👸'),
  ('Cape Superhero',  'Cape superhero untuk avatar',        70, 'avatar', '🦸'),

  -- Profile cosmetics
  ('Tema Biru',       'Tema warna biru untuk profil',      20, 'profile', '💎'),
  ('Tema Ungu',       'Tema warna ungu untuk profil',      20, 'profile', '💜'),
  ('Tema Emas',       'Tema warna emas untuk profil',      50, 'profile', '✨'),
  ('Stiker Panah',    'Koleksi stiker panah keren',        10, 'profile', '➡️'),
  ('Stiker Bintang',  'Koleksi stiker bintang berkilau',    10, 'profile', '⭐'),
  ('Border Perak',    'Border perak untuk kartu profil',    30, 'profile', '🥈'),
  ('Border Emas',     'Border emas untuk kartu profil',     60, 'profile', '🥇'),

  -- Premium items
  ('Efek Confetti',   'Efek confetti saat buka aplikasi',  80, 'premium', '🎊'),
  ('Hewan Peliharaan', 'Peliharaan virtual lucu',           100, 'premium', '🐰')
ON CONFLICT DO NOTHING;

-- RLS policies for store
ALTER TABLE store_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE child_store_purchases ENABLE ROW LEVEL SECURITY;

-- Everyone can read store items
CREATE POLICY "anyone read store_items"
  ON store_items FOR SELECT
  USING (is_active = true);

-- Children can view their own purchases
CREATE POLICY "children read own purchases"
  ON child_store_purchases FOR SELECT
  USING (child_id IN (
    SELECT id FROM child_profiles WHERE parent_id = auth.uid()
  ));

-- Children can insert their own purchases
CREATE POLICY "children insert own purchases"
  ON child_store_purchases FOR INSERT
  WITH CHECK (child_id IN (
    SELECT id FROM child_profiles WHERE parent_id = auth.uid()
  ));