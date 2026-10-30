-- ====================================================================
-- FIX TOP-UP, WITHDRAWAL, WALLET TRANSACTIONS & PROFILES RLS
-- Run this script in the Supabase Dashboard -> SQL Editor
-- ====================================================================

-- STEP 1: Drop ALL existing policies on topup_requests, withdrawal_requests & wallet_transactions
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN 
        SELECT policyname, tablename 
        FROM pg_policies 
        WHERE tablename IN ('topup_requests', 'withdrawal_requests', 'wallet_transactions', 'profiles') 
        AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.%I', pol.policyname, pol.tablename);
    END LOOP;
END $$;

-- STEP 2: Drop foreign key constraints on user_id so arbitrary / UUID candidate IDs work
ALTER TABLE public.topup_requests DROP CONSTRAINT IF EXISTS topup_requests_user_id_fkey;
ALTER TABLE public.withdrawal_requests DROP CONSTRAINT IF EXISTS withdrawal_requests_user_id_fkey;
ALTER TABLE public.wallet_transactions DROP CONSTRAINT IF EXISTS wallet_transactions_user_id_fkey;

-- STEP 3: Safely alter user_id column types to VARCHAR(128)
ALTER TABLE public.topup_requests ALTER COLUMN user_id TYPE VARCHAR(128);
ALTER TABLE public.withdrawal_requests ALTER COLUMN user_id TYPE VARCHAR(128);
ALTER TABLE public.wallet_transactions ALTER COLUMN user_id TYPE VARCHAR(128);

-- STEP 4: Add extra metadata columns for withdrawals if missing
ALTER TABLE public.withdrawal_requests ADD COLUMN IF NOT EXISTS user_name VARCHAR(100);
ALTER TABLE public.withdrawal_requests ADD COLUMN IF NOT EXISTS user_email VARCHAR(255);
ALTER TABLE public.withdrawal_requests ADD COLUMN IF NOT EXISTS user_phone VARCHAR(20);
ALTER TABLE public.withdrawal_requests ADD COLUMN IF NOT EXISTS payout_ref VARCHAR(100);

-- STEP 5: Enable Row Level Security on all financial tables
ALTER TABLE public.topup_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.withdrawal_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- STEP 6: Recreate clean, permissive policies for topup_requests
CREATE POLICY "Anyone can insert topup requests"
  ON public.topup_requests FOR INSERT TO authenticated, anon WITH CHECK (true);

CREATE POLICY "Anyone can view topup requests"
  ON public.topup_requests FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Anyone can manage topup requests"
  ON public.topup_requests FOR ALL TO authenticated, anon USING (true) WITH CHECK (true);

-- STEP 7: Recreate clean, permissive policies for withdrawal_requests
CREATE POLICY "Anyone can insert withdrawal requests"
  ON public.withdrawal_requests FOR INSERT TO authenticated, anon WITH CHECK (true);

CREATE POLICY "Anyone can view withdrawal requests"
  ON public.withdrawal_requests FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Anyone can manage withdrawal requests"
  ON public.withdrawal_requests FOR ALL TO authenticated, anon USING (true) WITH CHECK (true);

-- STEP 8: Permissive policies for wallet_transactions (allow user read & admin insert ledger)
CREATE POLICY "Anyone can read wallet transactions"
  ON public.wallet_transactions FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Anyone can insert wallet transactions"
  ON public.wallet_transactions FOR INSERT TO authenticated, anon WITH CHECK (true);

CREATE POLICY "Anyone can manage wallet transactions"
  ON public.wallet_transactions FOR ALL TO authenticated, anon USING (true) WITH CHECK (true);

-- STEP 9: Permissive policies for profiles (allow reading profile & updating coins)
CREATE POLICY "Anyone can read profiles"
  ON public.profiles FOR SELECT TO authenticated, anon USING (true);

CREATE POLICY "Anyone can update profiles"
  ON public.profiles FOR UPDATE TO authenticated, anon USING (true) WITH CHECK (true);

-- STEP 10: Atomic Superuser RPC for approving top-up requests
CREATE OR REPLACE FUNCTION public.admin_approve_topup(
  p_request_id VARCHAR,
  p_coins INT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_req RECORD;
  v_coins INT;
  v_new_balance BIGINT := 0;
  v_tx_id VARCHAR;
BEGIN
  -- 1. Fetch topup request
  SELECT * INTO v_req FROM public.topup_requests WHERE id = p_request_id FOR UPDATE;
  IF NOT FOUND THEN
    RETURN jsonb_build_object('success', false, 'message', 'Top-up request not found');
  END IF;

  v_coins := COALESCE(p_coins, v_req.coins_awarded::INT, 0);

  -- 2. Mark topup request as approved
  UPDATE public.topup_requests
  SET status = 'approved',
      processed_at = NOW()
  WHERE id = p_request_id;

  -- 3. Update candidate profile coins if profile exists
  IF EXISTS (SELECT 1 FROM public.profiles WHERE id::TEXT = v_req.user_id) THEN
    UPDATE public.profiles
    SET coins = COALESCE(coins, 0) + v_coins,
        total_earned = COALESCE(total_earned, 0) + v_coins,
        updated_at = NOW()
    WHERE id::TEXT = v_req.user_id
    RETURNING coins INTO v_new_balance;
  END IF;

  -- 4. Record audit ledger entry in wallet_transactions
  v_tx_id := 'TXN_' || EXTRACT(EPOCH FROM NOW())::BIGINT || '_' || SUBSTRING(p_request_id FROM 1 FOR 6);
  INSERT INTO public.wallet_transactions (
    id, user_id, amount, type, category, reference_id, title, balance_after, created_at
  ) VALUES (
    v_tx_id,
    v_req.user_id,
    v_coins,
    'earn',
    'topup',
    COALESCE(v_req.utr, p_request_id),
    'UPI Top-up Approved (UTR: ' || COALESCE(v_req.utr, 'Verified') || ')',
    v_new_balance,
    NOW()
  );

  RETURN jsonb_build_object(
    'success', true,
    'coins_added', v_coins,
    'new_balance', v_new_balance,
    'user_id', v_req.user_id
  );
END;
$$;

-- STEP 11: One-time Sync for already approved top-up requests that were blocked by old RLS
DO $$
DECLARE
  r RECORD;
  v_new_bal BIGINT;
BEGIN
  FOR r IN 
    SELECT * FROM public.topup_requests WHERE status = 'approved'
  LOOP
    IF NOT EXISTS (
      SELECT 1 FROM public.wallet_transactions 
      WHERE reference_id = r.utr OR id LIKE '%' || r.id || '%'
    ) THEN
      -- Credit candidate coins
      UPDATE public.profiles
      SET coins = COALESCE(coins, 0) + r.coins_awarded,
          total_earned = COALESCE(total_earned, 0) + r.coins_awarded,
          updated_at = NOW()
      WHERE id::TEXT = r.user_id
      RETURNING coins INTO v_new_bal;

      -- Insert missing transaction entry
      INSERT INTO public.wallet_transactions (
        id, user_id, amount, type, category, reference_id, title, balance_after, created_at
      ) VALUES (
        'TXN_' || EXTRACT(EPOCH FROM NOW())::BIGINT || '_' || SUBSTRING(r.id FROM 1 FOR 6),
        r.user_id,
        r.coins_awarded,
        'earn',
        'topup',
        r.utr,
        'UPI Top-up Approved (UTR: ' || r.utr || ')',
        COALESCE(v_new_bal, r.coins_awarded),
        COALESCE(r.created_at, NOW())
      );
    END IF;
  END LOOP;
END $$;

-- STEP 12: Realtime publication
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

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
    AND schemaname = 'public' 
    AND tablename = 'wallet_transactions'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.wallet_transactions;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
    AND schemaname = 'public' 
    AND tablename = 'profiles'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.profiles;
  END IF;
END $$;
