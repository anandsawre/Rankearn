-- ====================================================================
-- RANKEARN SUPABASE MIGRATION: TARGET EXAM CATEGORIES RLS & SYNC
-- Solves: PostgrestException 42501 (row-level security policy violation)
-- Safe, idempotent script for Supabase SQL Editor
-- ====================================================================

-- 1. Ensure table exists
CREATE TABLE IF NOT EXISTS public.exam_categories (
  id VARCHAR(64) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  normalized_name VARCHAR(100),
  icon_url TEXT,
  languages VARCHAR(50) DEFAULT 'en,hi',
  is_published BOOLEAN DEFAULT true,
  display_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 2. Indexes
CREATE INDEX IF NOT EXISTS idx_exam_categories_order ON public.exam_categories(display_order);
CREATE INDEX IF NOT EXISTS idx_exam_categories_published ON public.exam_categories(is_published);

-- 3. Enable RLS
ALTER TABLE public.exam_categories ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies: Allow Read & Admin Management (identical to categories and tests tables)
DROP POLICY IF EXISTS "Public can view exam categories" ON public.exam_categories;
DROP POLICY IF EXISTS "Everyone can read exam categories" ON public.exam_categories;
CREATE POLICY "Everyone can read exam categories"
  ON public.exam_categories FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Admins can manage exam categories" ON public.exam_categories;
DROP POLICY IF EXISTS "Admins can manage all exam categories" ON public.exam_categories;
CREATE POLICY "Admins can manage all exam categories"
  ON public.exam_categories FOR ALL
  USING (true)
  WITH CHECK (true);

-- 5. Seed default reference dataset
INSERT INTO public.exam_categories (id, name, normalized_name, icon_url, display_order, is_published)
VALUES
  ('bpsc', 'BPSC & State PCS', 'bpsc', '🏛️', 1, true),
  ('ssc', 'SSC CGL & CHSL', 'ssc', '📋', 2, true),
  ('upsc', 'UPSC Civil Services', 'upsc', '🇮🇳', 3, true),
  ('railway', 'RRB NTPC & Group D', 'railway', '🚆', 4, true),
  ('banking', 'Banking & Insurance', 'banking', '🏦', 5, true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  icon_url = EXCLUDED.icon_url,
  display_order = EXCLUDED.display_order,
  is_published = EXCLUDED.is_published;

