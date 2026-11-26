-- ====================================================================
-- FIX BATTLE_QUESTIONS RLS POLICIES
-- Fixes PostgrestException 42501:
-- "new row violates row-level security policy for table battle_questions"
-- ====================================================================

ALTER TABLE public.battle_questions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Authenticated users can read battle questions" ON public.battle_questions;
DROP POLICY IF EXISTS "Admins can manage battle questions" ON public.battle_questions;
DROP POLICY IF EXISTS "Anyone can read battle questions" ON public.battle_questions;
DROP POLICY IF EXISTS "Anyone can manage battle questions" ON public.battle_questions;

CREATE POLICY "Anyone can read battle questions"
  ON public.battle_questions FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Anyone can manage battle questions"
  ON public.battle_questions FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);
