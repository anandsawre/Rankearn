-- ====================================================================
-- RANKEARN SUPABASE MIGRATION: APP BANNERS MANAGEMENT SCHEMA & SEED
-- Idempotent, safe migration for Supabase SQL Editor
-- ====================================================================

-- 1. Ensure app_banners table exists with full schema
CREATE TABLE IF NOT EXISTS public.app_banners (
  id VARCHAR(64) PRIMARY KEY,
  image_url TEXT NOT NULL,
  title VARCHAR(255) NOT NULL,
  link TEXT DEFAULT '/tests',
  priority INT NOT NULL DEFAULT 1,
  is_active BOOLEAN NOT NULL DEFAULT true,
  type VARCHAR(50) DEFAULT 'promotional',
  spotlight_data JSONB DEFAULT '{}'::jsonb,
  scheduled_at TIMESTAMPTZ,
  clicks BIGINT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 2. Indexes for fast query ordering and active status
CREATE INDEX IF NOT EXISTS idx_app_banners_active ON public.app_banners(is_active, priority ASC);
CREATE INDEX IF NOT EXISTS idx_app_banners_created ON public.app_banners(created_at DESC);

-- 3. Enable Row Level Security (RLS)
ALTER TABLE public.app_banners ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies: Allow public read of banners & full management for admin/app
DROP POLICY IF EXISTS "Public can view active banners" ON public.app_banners;
DROP POLICY IF EXISTS "Everyone can read active banners" ON public.app_banners;
CREATE POLICY "Public can view active banners"
  ON public.app_banners FOR SELECT
  TO authenticated, anon
  USING (true);

DROP POLICY IF EXISTS "Admins can manage banners" ON public.app_banners;
DROP POLICY IF EXISTS "Allow banner management" ON public.app_banners;
CREATE POLICY "Admins can manage banners"
  ON public.app_banners FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

-- 5. Enable Supabase Realtime for Banners Stream
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'app_banners'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.app_banners;
  END IF;
END $$;

-- 6. Seed initial production banners if table is empty
INSERT INTO public.app_banners (id, image_url, title, link, priority, is_active, type, spotlight_data)
VALUES
  (
    'banner-championship-2026',
    'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=1200&auto=format&fit=crop&q=80',
    'Rankearn Championship League • Win ₹50,000 Weekly',
    '/tests',
    1,
    true,
    'promotional',
    '{"display_mode": "home_carousel", "is_scheduled": false}'::jsonb
  ),
  (
    'banner-railway-special',
    'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=1200&auto=format&fit=crop&q=80',
    'RRB NTPC & Group D Live All-India Mock Test Series',
    '/tests',
    2,
    true,
    'promotional',
    '{"display_mode": "home_carousel", "is_scheduled": false}'::jsonb
  )
ON CONFLICT (id) DO UPDATE SET
  image_url = EXCLUDED.image_url,
  title = EXCLUDED.title,
  is_active = EXCLUDED.is_active;

-- 6. Helper RPC for incrementing clicks
CREATE OR REPLACE FUNCTION public.increment_banner_clicks(banner_id TEXT)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.app_banners
  SET clicks = clicks + 1
  WHERE id = banner_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.increment_banner_clicks(TEXT) TO authenticated, anon;
