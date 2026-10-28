-- ====================================================================
-- FIX QUESTIONS IMPORT CONSTRAINTS AND PERMISSIVE POLICIES
-- Run this in Supabase Dashboard -> SQL Editor
-- ====================================================================

-- 1. Make test_id nullable so Question Bank questions can be saved standalone
ALTER TABLE public.questions ALTER COLUMN test_id DROP NOT NULL;

-- 2. Drop strict foreign key constraint so questions can be imported before/alongside mock tests
ALTER TABLE public.questions DROP CONSTRAINT IF EXISTS questions_test_id_fkey;

-- 3. Drop category constraints on tests if present so arbitrary subjects can be imported
ALTER TABLE public.tests DROP CONSTRAINT IF EXISTS tests_category_id_fkey;
ALTER TABLE public.tests DROP CONSTRAINT IF EXISTS tests_exam_category_id_fkey;

-- 4. Ensure RLS is active
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tests ENABLE ROW LEVEL SECURITY;

-- 5. Drop old restrictive policies
DROP POLICY IF EXISTS "Anyone can read test questions" ON public.questions;
DROP POLICY IF EXISTS "Admins and managers can manage questions" ON public.questions;
DROP POLICY IF EXISTS "Admins can manage questions" ON public.questions;
DROP POLICY IF EXISTS "Authenticated users can read test questions" ON public.questions;

DROP POLICY IF EXISTS "Everyone can read tests" ON public.tests;
DROP POLICY IF EXISTS "Admins can manage tests" ON public.tests;
DROP POLICY IF EXISTS "Everyone can read published tests" ON public.tests;

-- 6. Create permissive policies for questions (read & write for Admin and User apps)
CREATE POLICY "Allow public read questions"
  ON public.questions FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Allow public manage questions"
  ON public.questions FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

-- 7. Create permissive policies for tests
CREATE POLICY "Allow public read tests"
  ON public.tests FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Allow public manage tests"
  ON public.tests FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

-- 8. Add a default question bank test placeholder if not exists
INSERT INTO public.tests (id, title, test_mode, duration_minutes, total_questions, status, category_id)
VALUES ('general-question-bank', 'General Question Bank', 'mock', 60, 0, 'published', 'General')
ON CONFLICT (id) DO NOTHING;
