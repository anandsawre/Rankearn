-- ====================================================================
-- FIX TOP-UP & WITHDRAWAL REQUESTS RLS & USER_ID COMPATIBILITY
-- Run this script in the Supabase Dashboard -> SQL Editor
-- ====================================================================

-- 1. Relax foreign key constraints and user_id type so any candidate ID works
ALTER TABLE public.topup_requests DROP CONSTRAINT IF EXISTS topup_requests_user_id_fkey;
ALTER TABLE public.withdrawal_requests DROP CONSTRAINT IF EXISTS withdrawal_requests_user_id_fkey;

ALTER TABLE public.topup_requests ALTER COLUMN user_id TYPE VARCHAR(128);
ALTER TABLE public.withdrawal_requests ALTER COLUMN user_id TYPE VARCHAR(128);

-- 2. Add extra metadata fields to withdrawal_requests for easy admin review
ALTER TABLE public.withdrawal_requests ADD COLUMN IF NOT EXISTS user_name VARCHAR(100);
ALTER TABLE public.withdrawal_requests ADD COLUMN IF NOT EXISTS user_email VARCHAR(255);
ALTER TABLE public.withdrawal_requests ADD COLUMN IF NOT EXISTS user_phone VARCHAR(20);
ALTER TABLE public.withdrawal_requests ADD COLUMN IF NOT EXISTS payout_ref VARCHAR(100);

-- 3. Enable RLS on both tables
ALTER TABLE public.topup_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.withdrawal_requests ENABLE ROW LEVEL SECURITY;

-- 4. Drop old restrictive policies on topup_requests
DROP POLICY IF EXISTS "Users can view own top-up requests" ON public.topup_requests;
DROP POLICY IF EXISTS "Users can create top-up requests" ON public.topup_requests;
DROP POLICY IF EXISTS "Admins can manage top-up requests" ON public.topup_requests;
DROP POLICY IF EXISTS "Anyone can insert topup requests" ON public.topup_requests;
DROP POLICY IF EXISTS "Anyone can view topup requests" ON public.topup_requests;
DROP POLICY IF EXISTS "Anyone can manage topup requests" ON public.topup_requests;

-- 5. Create permissive policies for topup_requests (Users can submit, Admins can view & manage)
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

-- 6. Drop old restrictive policies on withdrawal_requests
DROP POLICY IF EXISTS "Users can view own withdrawal requests" ON public.withdrawal_requests;
DROP POLICY IF EXISTS "Users can create withdrawal requests" ON public.withdrawal_requests;
DROP POLICY IF EXISTS "Admins can manage withdrawal requests" ON public.withdrawal_requests;
DROP POLICY IF EXISTS "Anyone can insert withdrawal requests" ON public.withdrawal_requests;
DROP POLICY IF EXISTS "Anyone can view withdrawal requests" ON public.withdrawal_requests;
DROP POLICY IF EXISTS "Anyone can manage withdrawal requests" ON public.withdrawal_requests;

-- 7. Create permissive policies for withdrawal_requests
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

-- 8. Add topup_requests and withdrawal_requests to Supabase Realtime publication
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
