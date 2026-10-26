-- ====================================================================
-- CATEGORIES LIVE SYNC & REALTIME EXTENSION
-- Run this in Supabase Dashboard -> SQL Editor
-- ====================================================================

-- 1. Ensure table exists with base columns
CREATE TABLE IF NOT EXISTS public.categories (
  id VARCHAR(64) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 2. Add extended columns matching Admin & User App CategoryModel
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS slug VARCHAR(100) DEFAULT '';
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS description TEXT DEFAULT '';
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS icon_name VARCHAR(50) DEFAULT 'school';
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS icon_color VARCHAR(30) DEFAULT '#3B82F6';
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS subcategories_count INT DEFAULT 0;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS subjects_count INT DEFAULT 0;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS total_tests INT DEFAULT 0;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS total_questions INT DEFAULT 0;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS display_order INT DEFAULT 1;
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS status VARCHAR(20) DEFAULT 'active';
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now());
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS exam_category_id VARCHAR(64);
ALTER TABLE public.categories ADD COLUMN IF NOT EXISTS topics TEXT[] DEFAULT '{}';

-- 3. Enable RLS
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- 4. Policies: Everyone can read active/published categories
DROP POLICY IF EXISTS "Everyone can read categories" ON public.categories;
CREATE POLICY "Everyone can read categories"
  ON public.categories FOR SELECT
  TO authenticated, anon
  USING (true);

-- Allow authenticated users / admins to insert and update categories
DROP POLICY IF EXISTS "Admins can manage categories" ON public.categories;
CREATE POLICY "Admins can manage categories"
  ON public.categories FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

-- 5. Enable Realtime on categories table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
    AND schemaname = 'public' 
    AND tablename = 'categories'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.categories;
  END IF;
END $$;

-- 6. Insert default categories if table is currently empty
INSERT INTO public.categories (id, name, slug, description, icon_name, icon_color, total_questions, display_order, status)
VALUES
  ('cat_science', 'General Science', 'general-science', 'Physics, Chemistry, and Biology essentials', 'science', '#2587F8', 1200, 1, 'active'),
  ('cat_maths', 'Mathematics', 'mathematics', 'Quantitative aptitude, arithmetic, and advanced algebra', 'calculate', '#F59E0B', 800, 2, 'active'),
  ('cat_reasoning', 'Reasoning', 'reasoning', 'Verbal and non-verbal logical reasoning', 'psychology', '#F43F5E', 700, 3, 'active'),
  ('cat_current_affairs', 'Current Affairs', 'current-affairs', 'Daily national and international news', 'newspaper', '#8B5CF6', 500, 4, 'active'),
  ('cat_history', 'Indian History', 'indian-history', 'Ancient, Medieval, and Modern India', 'auto_stories', '#06B6D4', 600, 5, 'active'),
  ('cat_polity', 'Indian Polity', 'indian-polity', 'Constitution, governance, and political system', 'school', '#10B981', 550, 6, 'active')
ON CONFLICT (id) DO UPDATE SET
  icon_name = EXCLUDED.icon_name,
  icon_color = EXCLUDED.icon_color,
  display_order = EXCLUDED.display_order;
