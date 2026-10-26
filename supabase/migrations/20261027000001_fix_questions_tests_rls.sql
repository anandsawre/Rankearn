-- ====================================================================
-- FIX QUESTIONS & TESTS RLS POLICIES FOR ADMIN & USER SYNC
-- Run this script in the Supabase Dashboard -> SQL Editor
-- ====================================================================

-- 1. Ensure RLS is active & make test_id nullable for question bank
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ALTER COLUMN test_id DROP NOT NULL;

-- Remove strict category_id FK on tests so arbitrary category/subject names can be saved
ALTER TABLE public.tests DROP CONSTRAINT IF EXISTS tests_category_id_fkey;
ALTER TABLE public.tests DROP CONSTRAINT IF EXISTS tests_exam_category_id_fkey;

-- 2. Drop existing restrictive policies on questions
DROP POLICY IF EXISTS "Authenticated users can read test questions" ON public.questions;
DROP POLICY IF EXISTS "Admins can manage questions" ON public.questions;
DROP POLICY IF EXISTS "Anyone can read test questions" ON public.questions;
DROP POLICY IF EXISTS "Admins and managers can manage questions" ON public.questions;

-- 3. Create permissive policies for questions
-- Allow users and guests to read questions of tests
CREATE POLICY "Anyone can read test questions"
  ON public.questions FOR SELECT
  TO authenticated, anon
  USING (true);

-- Allow Admin App (authenticated and anon clients) full CRUD on questions
CREATE POLICY "Admins and managers can manage questions"
  ON public.questions FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

-- 4. Drop existing restrictive policies on tests
DROP POLICY IF EXISTS "Everyone can read published tests" ON public.tests;
DROP POLICY IF EXISTS "Admins can manage tests" ON public.tests;
DROP POLICY IF EXISTS "Everyone can read tests" ON public.tests;

-- 5. Create permissive policies for tests
CREATE POLICY "Everyone can read tests"
  ON public.tests FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Admins can manage tests"
  ON public.tests FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

-- 6. Also update battle_questions if present
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'battle_questions') THEN
    ALTER TABLE public.battle_questions ENABLE ROW LEVEL SECURITY;
    DROP POLICY IF EXISTS "Authenticated users can read battle questions" ON public.battle_questions;
    DROP POLICY IF EXISTS "Admins can manage battle questions" ON public.battle_questions;
    DROP POLICY IF EXISTS "Anyone can read battle questions" ON public.battle_questions;

    CREATE POLICY "Anyone can read battle questions"
      ON public.battle_questions FOR SELECT
      TO authenticated, anon
      USING (true);

    CREATE POLICY "Admins can manage battle questions"
      ON public.battle_questions FOR ALL
      TO authenticated, anon
      USING (true)
      WITH CHECK (true);
  END IF;
END $$;

-- 7. Ensure admin role mapping for any admin user
INSERT INTO public.user_roles (user_id, role)
SELECT id, 'admin'
FROM auth.users
WHERE email ILIKE '%admin%'
ON CONFLICT (user_id, role) DO NOTHING;

-- 8. Enable Realtime on questions & tests tables
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
    AND schemaname = 'public' 
    AND tablename = 'questions'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.questions;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
    AND schemaname = 'public' 
    AND tablename = 'tests'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.tests;
  END IF;
END $$;
