-- ====================================================================
-- RANKEARN MIGRATION: Add prize_pool_coins to tests table
-- Idempotent, safe migration for Supabase SQL Editor
-- ====================================================================

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'tests' AND column_name = 'prize_pool_coins'
  ) THEN
    ALTER TABLE public.tests ADD COLUMN prize_pool_coins INT DEFAULT 1500;
  END IF;
END $$;
