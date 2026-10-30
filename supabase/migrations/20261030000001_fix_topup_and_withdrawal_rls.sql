-- ====================================================================
-- FIX TOP-UP & WITHDRAWAL REQUESTS RLS & USER_ID COMPATIBILITY
-- Run this script in the Supabase Dashboard -> SQL Editor
-- ====================================================================

-- STEP 1: Drop ALL existing policies on topup_requests and withdrawal_requests FIRST
-- (PostgreSQL does not allow altering column type if any policy references that column)
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN 
        SELECT policyname, tablename 
        FROM pg_policies 
        WHERE tablename IN ('topup_requests', 'withdrawal_requests') AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', pol.policyname, pol.tablename);
    END LOOP;
END $$;

-- STEP 2: Drop foreign key constraints
ALTER TABLE public.topup_requests DROP CONSTRAINT IF EXISTS topup_requests_user_id_fkey;
ALTER TABLE public.withdrawal_requests DROP CONSTRAINT IF EXISTS withdrawal_requests_user_id_fkey;

-- STEP 3: Now safely alter column types to VARCHAR (no policies or FKs blocking it)
ALTER TABLE public.topup_requests ALTER COLUMN user_id TYPE VARCHAR(128);
ALTER TABLE public.withdrawal_requests ALTER COLUMN user_id TYPE VARCHAR(128);

-- STEP 4: Add extra metadata columns for withdrawal reviews
ALTER TABLE public.withdrawal_requests ADD COLUMN IF NOT EXISTS user_name VARCHAR(100);
ALTER TABLE public.withdrawal_requests ADD COLUMN IF NOT EXISTS user_email VARCHAR(255);
ALTER TABLE public.withdrawal_requests ADD COLUMN IF NOT EXISTS user_phone VARCHAR(20);
ALTER TABLE public.withdrawal_requests ADD COLUMN IF NOT EXISTS payout_ref VARCHAR(100);

-- STEP 5: Enable Row Level Security
ALTER TABLE public.topup_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.withdrawal_requests ENABLE ROW LEVEL SECURITY;

-- STEP 6: Recreate clean, permissive policies for topup_requests
CREATE POLICY "Anyone can insert topup requests"
  ON public.topup_requests FOR INSERT
  TO authenticated, anon
  WITH CHECK (true);

CREATE POLICY "Anyone can view topup requests"
  ON public.topup_requests FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Anyone can manage topup requests"
  ON public.topup_requests FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

-- STEP 7: Recreate clean, permissive policies for withdrawal_requests
CREATE POLICY "Anyone can insert withdrawal requests"
  ON public.withdrawal_requests FOR INSERT
  TO authenticated, anon
  WITH CHECK (true);

CREATE POLICY "Anyone can view withdrawal requests"
  ON public.withdrawal_requests FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Anyone can manage withdrawal requests"
  ON public.withdrawal_requests FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

-- STEP 8: Add to Supabase Realtime publication
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
    AND schemaname = 'public' 
    AND tablename = 'topup_requests'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.topup_requests;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
    AND schemaname = 'public' 
    AND tablename = 'withdrawal_requests'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.withdrawal_requests;
  END IF;
END $$;
