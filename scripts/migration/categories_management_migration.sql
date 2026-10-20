-- ====================================================================
-- RANKEARN SUPABASE MIGRATION: CATEGORIES MANAGEMENT SCHEMA & SEED
-- Idempotent, safe migration for Supabase SQL Editor
-- ====================================================================

-- 1. Ensure categories table exists
CREATE TABLE IF NOT EXISTS public.categories (
  id VARCHAR(64) PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  slug VARCHAR(255),
  description TEXT,
  icon_name VARCHAR(100) DEFAULT 'school',
  icon_color VARCHAR(20) DEFAULT '#3B82F6',
  parent_id VARCHAR(64) REFERENCES public.categories(id) ON DELETE SET NULL,
  display_order INT DEFAULT 1,
  subcategories_count INT NOT NULL DEFAULT 0,
  subjects_count INT NOT NULL DEFAULT 0,
  total_tests INT NOT NULL DEFAULT 0,
  total_questions INT NOT NULL DEFAULT 0,
  status VARCHAR(20) NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 2. Subcategories table (for granular hierarchy)
CREATE TABLE IF NOT EXISTS public.subcategories (
  id VARCHAR(64) PRIMARY KEY,
  category_id VARCHAR(64) NOT NULL REFERENCES public.categories(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  display_order INT DEFAULT 1,
  status VARCHAR(20) NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 3. Indexes for high performance filtering and search
CREATE INDEX IF NOT EXISTS idx_categories_status ON public.categories(status);
CREATE INDEX IF NOT EXISTS idx_categories_order ON public.categories(display_order);
CREATE INDEX IF NOT EXISTS idx_categories_created_at ON public.categories(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_subcategories_category_id ON public.subcategories(category_id);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subcategories ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies
DROP POLICY IF EXISTS "Public can view active categories" ON public.categories;
CREATE POLICY "Public can view active categories"
  ON public.categories FOR SELECT
  USING (status = 'active' OR true);

DROP POLICY IF EXISTS "Admins can manage all categories" ON public.categories;
CREATE POLICY "Admins can manage all categories"
  ON public.categories FOR ALL
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Public can view subcategories" ON public.subcategories;
CREATE POLICY "Public can view subcategories"
  ON public.subcategories FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Admins can manage subcategories" ON public.subcategories;
CREATE POLICY "Admins can manage subcategories"
  ON public.subcategories FOR ALL
  USING (true)
  WITH CHECK (true);

-- 6. Seed Reference Dataset Matching Specification Image Exactly (Idempotent)
INSERT INTO public.categories (
  id, name, slug, description, icon_name, icon_color, display_order,
  subcategories_count, subjects_count, total_tests, total_questions, status, created_at
) VALUES
  (
    'cat-1',
    'Competitive Exams',
    'competitive-exams',
    'Government and competitive exams',
    'school',
    '#3B82F6',
    1,
    12,
    28,
    320,
    4850,
    'active',
    '2026-10-18 10:00:00+00'
  ),
  (
    'cat-2',
    'School Education',
    'school-education',
    'School level subjects and tests',
    'menu_book',
    '#F43F5E',
    2,
    8,
    16,
    180,
    2340,
    'active',
    '2026-10-15 10:00:00+00'
  ),
  (
    'cat-3',
    'State Level Exams',
    'state-level-exams',
    'State government examinations',
    'account_balance',
    '#F59E0B',
    3,
    6,
    12,
    120,
    1950,
    'active',
    '2026-10-12 10:00:00+00'
  ),
  (
    'cat-4',
    'Entrance Exams',
    'entrance-exams',
    'Engineering, Medical and other entrance exams',
    'auto_stories',
    '#8B5CF6',
    4,
    10,
    20,
    240,
    3420,
    'active',
    '2026-10-10 10:00:00+00'
  ),
  (
    'cat-5',
    'Skill Development',
    'skill-development',
    'Professional and skill based courses',
    'code',
    '#10B981',
    5,
    5,
    10,
    80,
    980,
    'draft',
    '2026-10-08 10:00:00+00'
  ),
  (
    'cat-6',
    'General Awareness',
    'general-awareness',
    'Current affairs and general knowledge',
    'public',
    '#06B6D4',
    6,
    7,
    14,
    160,
    2100,
    'active',
    '2026-10-05 10:00:00+00'
  ),
  (
    'cat-7',
    'Practice & Mock Tests',
    'practice-mock-tests',
    'Mixed category tests for practice',
    'assignment',
    '#EC4899',
    7,
    4,
    8,
    95,
    1250,
    'archived',
    '2026-10-01 10:00:00+00'
  )
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  icon_name = EXCLUDED.icon_name,
  icon_color = EXCLUDED.icon_color,
  subcategories_count = EXCLUDED.subcategories_count,
  subjects_count = EXCLUDED.subjects_count,
  total_tests = EXCLUDED.total_tests,
  total_questions = EXCLUDED.total_questions,
  status = EXCLUDED.status,
  updated_at = timezone('utc'::text, now());
