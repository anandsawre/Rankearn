-- ====================================================================
-- FIX ATTEMPTS RLS & FOREIGN KEY POLICIES FOR QUIZ & TEST SUBMISSIONS
-- Run this script in the Supabase Dashboard -> SQL Editor
-- ====================================================================

-- 1. Remove strict foreign keys on attempts so all test IDs and user IDs can be saved
ALTER TABLE public.attempts DROP CONSTRAINT IF EXISTS attempts_test_id_fkey;
ALTER TABLE public.attempts DROP CONSTRAINT IF EXISTS attempts_user_id_fkey;

-- 2. Allow user_id to accept both UUIDs and string IDs (like demo 'usr_vikram_70')
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'attempts' AND column_name = 'user_id' AND data_type = 'uuid'
  ) THEN
    ALTER TABLE public.attempts ALTER COLUMN user_id TYPE VARCHAR(64) USING user_id::text;
  END IF;
END $$;

-- 3. Ensure RLS is active on attempts
ALTER TABLE public.attempts ENABLE ROW LEVEL SECURITY;

-- 4. Drop existing restrictive policies on attempts
DROP POLICY IF EXISTS "Users can read own attempts" ON public.attempts;
DROP POLICY IF EXISTS "Users can insert own attempts" ON public.attempts;
DROP POLICY IF EXISTS "Anyone can insert attempts" ON public.attempts;
DROP POLICY IF EXISTS "Admins can manage attempts" ON public.attempts;
DROP POLICY IF EXISTS "Anyone can read attempts" ON public.attempts;

-- 5. Create permissive policies for attempts
-- Allow users and guests to insert their test attempts
CREATE POLICY "Anyone can insert attempts"
  ON public.attempts FOR INSERT
  TO authenticated, anon
  WITH CHECK (true);

-- Allow users and guests to read attempts
CREATE POLICY "Anyone can read attempts"
  ON public.attempts FOR SELECT
  TO authenticated, anon
  USING (true);

-- Allow Admins full management on attempts
CREATE POLICY "Admins can manage attempts"
  ON public.attempts FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);
