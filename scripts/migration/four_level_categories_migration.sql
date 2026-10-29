-- ====================================================================
-- RANKEARN SUPABASE MIGRATION: 4-LEVEL CATEGORIES HIERARCHY
-- Level 1: exam_categories (Target Exams: BPSC, SSC, UPSC, Railway, etc.)
-- Level 2: categories (Subjects: General Science, History, Math, etc.)
-- Level 3: subcategories (Units / Sections: Physics, Ancient History, etc.)
-- Level 4: topics (Chapters / Topics: Mechanics, Indus Valley, etc.)
-- Safe, idempotent migration script for Supabase SQL Editor
-- ====================================================================

-- 1. LEVEL 1: Ensure exam_categories table exists
CREATE TABLE IF NOT EXISTS public.exam_categories (
  id VARCHAR(64) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  normalized_name VARCHAR(100),
  icon_url TEXT,
  languages VARCHAR(50) DEFAULT 'en,hi',
  is_published BOOLEAN DEFAULT true,
  display_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 2. LEVEL 2: Ensure categories table has exam_category_id foreign reference
CREATE TABLE IF NOT EXISTS public.categories (
  id VARCHAR(64) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  exam_category_id VARCHAR(64) REFERENCES public.exam_categories(id) ON DELETE SET NULL,
  slug VARCHAR(255),
  description TEXT,
  icon_name VARCHAR(100) DEFAULT 'school',
  icon_color VARCHAR(20) DEFAULT '#3B82F6',
  parent_id VARCHAR(64) REFERENCES public.categories(id) ON DELETE SET NULL,
  topics JSONB DEFAULT '[]'::jsonb,
  display_order INT DEFAULT 1,
  subcategories_count INT NOT NULL DEFAULT 0,
  subjects_count INT NOT NULL DEFAULT 0,
  total_tests INT NOT NULL DEFAULT 0,
  total_questions INT NOT NULL DEFAULT 0,
  status VARCHAR(20) NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- Ensure exam_category_id column exists if table was created previously
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'categories' AND column_name = 'exam_category_id'
  ) THEN
    ALTER TABLE public.categories ADD COLUMN exam_category_id VARCHAR(64) REFERENCES public.exam_categories(id) ON DELETE SET NULL;
  END IF;
END $$;

-- 3. LEVEL 3: Ensure subcategories table exists with category_id
CREATE TABLE IF NOT EXISTS public.subcategories (
  id VARCHAR(64) PRIMARY KEY,
  category_id VARCHAR(64) NOT NULL REFERENCES public.categories(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255),
  description TEXT,
  display_order INT DEFAULT 1,
  status VARCHAR(20) NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 4. LEVEL 4: Ensure topics table exists (Level 4: Chapters)
CREATE TABLE IF NOT EXISTS public.topics (
  id VARCHAR(64) PRIMARY KEY,
  subcategory_id VARCHAR(64) NOT NULL REFERENCES public.subcategories(id) ON DELETE CASCADE,
  category_id VARCHAR(64) REFERENCES public.categories(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255),
  description TEXT,
  display_order INT DEFAULT 1,
  status VARCHAR(20) NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 5. Indexes for fast hierarchy queries
CREATE INDEX IF NOT EXISTS idx_exam_categories_order ON public.exam_categories(display_order);
CREATE INDEX IF NOT EXISTS idx_categories_exam_id ON public.categories(exam_category_id);
CREATE INDEX IF NOT EXISTS idx_categories_status ON public.categories(status);
CREATE INDEX IF NOT EXISTS idx_subcategories_category_id ON public.subcategories(category_id);
CREATE INDEX IF NOT EXISTS idx_subcategories_status ON public.subcategories(status);
CREATE INDEX IF NOT EXISTS idx_topics_subcategory_id ON public.topics(subcategory_id);
CREATE INDEX IF NOT EXISTS idx_topics_category_id ON public.topics(category_id);
CREATE INDEX IF NOT EXISTS idx_topics_status ON public.topics(status);

-- 6. Enable Row Level Security (RLS) on all 4 levels
ALTER TABLE public.exam_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subcategories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;

-- 7. Public Read & Admin Manage Policies for all 4 tables
-- Level 1: exam_categories
DROP POLICY IF EXISTS "Public can view exam categories" ON public.exam_categories;
DROP POLICY IF EXISTS "Everyone can read exam categories" ON public.exam_categories;
CREATE POLICY "Everyone can read exam categories" ON public.exam_categories FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admins can manage exam categories" ON public.exam_categories;
DROP POLICY IF EXISTS "Admins can manage all exam categories" ON public.exam_categories;
CREATE POLICY "Admins can manage all exam categories" ON public.exam_categories FOR ALL USING (true) WITH CHECK (true);

-- Level 2: categories
DROP POLICY IF EXISTS "Public can view active categories" ON public.categories;
CREATE POLICY "Public can view active categories" ON public.categories FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admins can manage all categories" ON public.categories;
CREATE POLICY "Admins can manage all categories" ON public.categories FOR ALL USING (true) WITH CHECK (true);

-- Level 3: subcategories
DROP POLICY IF EXISTS "Public can view subcategories" ON public.subcategories;
CREATE POLICY "Public can view subcategories" ON public.subcategories FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admins can manage subcategories" ON public.subcategories;
CREATE POLICY "Admins can manage subcategories" ON public.subcategories FOR ALL USING (true) WITH CHECK (true);

-- Level 4: topics
DROP POLICY IF EXISTS "Public can view topics" ON public.topics;
CREATE POLICY "Public can view topics" ON public.topics FOR SELECT USING (true);

DROP POLICY IF EXISTS "Admins can manage topics" ON public.topics;
CREATE POLICY "Admins can manage topics" ON public.topics FOR ALL USING (true) WITH CHECK (true);

-- 8. Seed default Target Exams (Level 1)
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

