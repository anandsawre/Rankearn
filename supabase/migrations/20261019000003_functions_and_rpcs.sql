-- ====================================================================
-- RANK EARN SUPABASE SCHEMA MIGRATION 003: STORED PROCEDURES & RPCS
-- ====================================================================

-- 1. Trigger on auth.users: Handle New User Registration
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_ref_code VARCHAR(16);
  v_referrer_id UUID;
  v_ref_param TEXT;
  v_welcome_coins INT := 10;
BEGIN
  -- Generate unique 8-character referral code
  v_ref_code := UPPER(SUBSTRING(MD5(RANDOM()::TEXT || NEW.id::TEXT), 1, 8));

  -- Check if user arrived via a referral code
  v_ref_param := NEW.raw_user_meta_data->>'referral_code';
  IF v_ref_param IS NOT NULL AND v_ref_param <> '' THEN
    SELECT id INTO v_referrer_id FROM public.profiles WHERE referral_code = UPPER(v_ref_param);
  END IF;

  -- Create profile row
  INSERT INTO public.profiles (
    id,
    name,
    email,
    profile_photo_url,
    coins,
    referral_code,
    referred_by,
    created_at,
    updated_at
  ) VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', NEW.raw_user_meta_data->>'full_name', SPLIT_PART(NEW.email, '@', 1)),
    NEW.email,
    NEW.raw_user_meta_data->>'avatar_url',
    v_welcome_coins,
    v_ref_code,
    v_referrer_id,
    NOW(),
    NOW()
  );

  -- Log welcome bonus transaction
  IF v_welcome_coins > 0 THEN
    INSERT INTO public.wallet_transactions (
      id,
      user_id,
      amount,
      type,
      category,
      title,
      balance_after,
      created_at
    ) VALUES (
      'TX_WELCOME_' || SUBSTRING(NEW.id::TEXT, 1, 8) || '_' || EXTRACT(EPOCH FROM NOW())::BIGINT,
      NEW.id,
      v_welcome_coins,
      'earn',
      'reward',
      'Welcome Bonus Coins 🎁',
      v_welcome_coins,
      NOW()
    );
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ====================================================================
-- 2. Transactional RPC: Join Tournament
-- ====================================================================
CREATE OR REPLACE FUNCTION public.join_tournament(
  p_test_id VARCHAR,
  p_user_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_test RECORD;
  v_user RECORD;
  v_new_balance BIGINT;
  v_tx_id VARCHAR;
BEGIN
  -- Validate caller matches user ID
  IF auth.uid() <> p_user_id AND NOT public.is_admin() THEN
    RAISE EXCEPTION 'Unauthorized tournament join request';
  END IF;

  -- 1. Lock and fetch tournament
  SELECT * INTO v_test FROM public.tests WHERE id = p_test_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Tournament not found';
  END IF;

  IF NOT v_test.is_tournament THEN
    RAISE EXCEPTION 'This test is not a tournament contest';
  END IF;

  IF v_test.status <> 'published' THEN
    RAISE EXCEPTION 'Contest is not open for registration';
  END IF;

  IF v_test.scheduled_end_time IS NOT NULL AND NOW() > v_test.scheduled_end_time THEN
    RAISE EXCEPTION 'Contest has already ended';
  END IF;

  IF v_test.total_participants >= v_test.max_participants THEN
    RAISE EXCEPTION 'Contest has reached maximum capacity';
  END IF;

  -- 2. Check if already participating
  IF EXISTS (SELECT 1 FROM public.tournament_participants WHERE test_id = p_test_id AND user_id = p_user_id) THEN
    RETURN jsonb_build_object('success', true, 'message', 'Already registered');
  END IF;

  -- 3. Lock user profile and check coins
  SELECT * INTO v_user FROM public.profiles WHERE id = p_user_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User profile not found';
  END IF;

  IF v_user.coins < v_test.entry_fee_coins THEN
    RAISE EXCEPTION 'Insufficient coins balance';
  END IF;

  -- 4. Deduct coins and update counts
  v_new_balance := v_user.coins - v_test.entry_fee_coins;
  UPDATE public.profiles
  SET coins = v_new_balance,
      total_spent = total_spent + v_test.entry_fee_coins,
      is_leaderboard_eligible = true,
      updated_at = NOW()
  WHERE id = p_user_id;

  UPDATE public.tests
  SET total_participants = total_participants + 1,
      updated_at = NOW()
  WHERE id = p_test_id;

  INSERT INTO public.tournament_participants (test_id, user_id, fee_paid, joined_at)
  VALUES (p_test_id, p_user_id, v_test.entry_fee_coins, NOW());

  -- 5. Log transaction
  v_tx_id := 'TX_JOIN_' || SUBSTRING(p_test_id, 1, 8) || '_' || EXTRACT(EPOCH FROM NOW())::BIGINT;
  IF v_test.entry_fee_coins > 0 THEN
    INSERT INTO public.wallet_transactions (
      id, user_id, amount, type, category, reference_id, title, balance_after, created_at
    ) VALUES (
      v_tx_id, p_user_id, -v_test.entry_fee_coins, 'spend', 'tournament_entry', p_test_id,
      'Joined Contest: ' || v_test.title, v_new_balance, NOW()
    );
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'new_balance', v_new_balance,
    'total_participants', v_test.total_participants + 1
  );
END;
$$;

-- ====================================================================
-- 3. Transactional RPC: Unlock Test With Coins
-- ====================================================================
CREATE OR REPLACE FUNCTION public.unlock_test_with_coins(
  p_test_id VARCHAR,
  p_user_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_test RECORD;
  v_user RECORD;
  v_new_balance BIGINT;
  v_tx_id VARCHAR;
BEGIN
  IF auth.uid() <> p_user_id AND NOT public.is_admin() THEN
    RAISE EXCEPTION 'Unauthorized unlock request';
  END IF;

  SELECT * INTO v_test FROM public.tests WHERE id = p_test_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Test not found';
  END IF;

  -- Check if already unlocked
  IF EXISTS (SELECT 1 FROM public.unlocked_tests WHERE user_id = p_user_id AND test_id = p_test_id) THEN
    RETURN jsonb_build_object('success', true, 'message', 'Already unlocked');
  END IF;

  SELECT * INTO v_user FROM public.profiles WHERE id = p_user_id FOR UPDATE;
  IF v_user.coins < v_test.unlock_price_coins THEN
    RAISE EXCEPTION 'Insufficient coins balance';
  END IF;

  v_new_balance := v_user.coins - v_test.unlock_price_coins;
  UPDATE public.profiles
  SET coins = v_new_balance,
      total_spent = total_spent + v_test.unlock_price_coins,
      updated_at = NOW()
  WHERE id = p_user_id;

  INSERT INTO public.unlocked_tests (user_id, test_id, coins_paid, unlocked_at)
  VALUES (p_user_id, p_test_id, v_test.unlock_price_coins, NOW());

  v_tx_id := 'TX_UNLOCK_' || SUBSTRING(p_test_id, 1, 8) || '_' || EXTRACT(EPOCH FROM NOW())::BIGINT;
  INSERT INTO public.wallet_transactions (
    id, user_id, amount, type, category, reference_id, title, balance_after, created_at
  ) VALUES (
    v_tx_id, p_user_id, -v_test.unlock_price_coins, 'spend', 'unlock_test', p_test_id,
    'Unlocked Test: ' || v_test.title, v_new_balance, NOW()
  );

  RETURN jsonb_build_object('success', true, 'new_balance', v_new_balance);
END;
$$;

-- ====================================================================
-- 4. Transactional RPC: Spin Lucky Wheel
-- ====================================================================
CREATE OR REPLACE FUNCTION public.spin_lucky_wheel(
  p_user_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user RECORD;
  v_last_spin DATE;
  v_today DATE := (NOW() AT TIME ZONE 'UTC')::DATE;
  v_coins_won INT;
  v_slice_index INT;
  v_rand INT;
  v_new_balance BIGINT;
  v_tx_id VARCHAR;
BEGIN
  IF auth.uid() <> p_user_id AND NOT public.is_admin() THEN
    RAISE EXCEPTION 'Unauthorized wheel spin';
  END IF;

  SELECT * INTO v_user FROM public.profiles WHERE id = p_user_id FOR UPDATE;
  IF v_user.status <> 'active' THEN
    RAISE EXCEPTION 'Account is not active';
  END IF;

  IF v_user.last_spin_date IS NOT NULL THEN
    v_last_spin := (v_user.last_spin_date AT TIME ZONE 'UTC')::DATE;
    IF v_last_spin >= v_today THEN
      RAISE EXCEPTION 'You have already spun the wheel today. Come back tomorrow!';
    END IF;
  END IF;

  -- Deterministic random prize selection based on standard slices:
  -- Slice 0: 5 coins (30%)
  -- Slice 1: 10 coins (25%)
  -- Slice 2: 25 coins (15%)
  -- Slice 3: Try Again (10%)
  -- Slice 4: 50 coins (10%)
  -- Slice 5: 5 coins (5%)
  -- Slice 6: 100 coins (3%)
  -- Slice 7: 10 coins (2%)
  v_rand := FLOOR(RANDOM() * 100)::INT;
  IF v_rand < 30 THEN
    v_coins_won := 5; v_slice_index := 0;
  ELSIF v_rand < 55 THEN
    v_coins_won := 10; v_slice_index := 1;
  ELSIF v_rand < 70 THEN
    v_coins_won := 25; v_slice_index := 2;
  ELSIF v_rand < 80 THEN
    v_coins_won := 0; v_slice_index := 3;
  ELSIF v_rand < 90 THEN
    v_coins_won := 50; v_slice_index := 4;
  ELSIF v_rand < 95 THEN
    v_coins_won := 5; v_slice_index := 5;
  ELSIF v_rand < 98 THEN
    v_coins_won := 100; v_slice_index := 6;
  ELSE
    v_coins_won := 10; v_slice_index := 7;
  END IF;

  v_new_balance := v_user.coins + v_coins_won;
  UPDATE public.profiles
  SET coins = v_new_balance,
      total_earned = total_earned + v_coins_won,
      last_spin_date = NOW(),
      updated_at = NOW()
  WHERE id = p_user_id;

  IF v_coins_won > 0 THEN
    v_tx_id := 'TX_SPIN_' || EXTRACT(EPOCH FROM NOW())::BIGINT;
    INSERT INTO public.wallet_transactions (
      id, user_id, amount, type, category, title, balance_after, created_at
    ) VALUES (
      v_tx_id, p_user_id, v_coins_won, 'earn', 'spin_wheel',
      'Daily Wheel Spin: Won ' || v_coins_won || ' Coins', v_new_balance, NOW()
    );
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'slice_index', v_slice_index,
    'coins_won', v_coins_won,
    'new_balance', v_new_balance
  );
END;
$$;

-- ====================================================================
-- 5. Admin Finance RPC: Process Top-up Request
-- ====================================================================
CREATE OR REPLACE FUNCTION public.process_topup_request(
  p_request_id VARCHAR,
  p_action VARCHAR, -- 'approve' or 'reject'
  p_rejection_reason TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_req RECORD;
  v_user RECORD;
  v_new_balance BIGINT;
  v_tx_id VARCHAR;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Admin authorization required';
  END IF;

  SELECT * INTO v_req FROM public.topup_requests WHERE id = p_request_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Top-up request not found';
  END IF;

  IF v_req.status <> 'pending' THEN
    RAISE EXCEPTION 'Request has already been processed';
  END IF;

  IF p_action = 'approve' THEN
    SELECT * INTO v_user FROM public.profiles WHERE id = v_req.user_id FOR UPDATE;
    v_new_balance := v_user.coins + v_req.coins_awarded;

    UPDATE public.profiles
    SET coins = v_new_balance,
        total_earned = total_earned + v_req.coins_awarded,
        updated_at = NOW()
    WHERE id = v_req.user_id;

    UPDATE public.topup_requests
    SET status = 'approved',
        processed_by = auth.uid(),
        processed_at = NOW()
    WHERE id = p_request_id;

    v_tx_id := 'TX_TOPUP_' || SUBSTRING(p_request_id, 1, 8) || '_' || EXTRACT(EPOCH FROM NOW())::BIGINT;
    INSERT INTO public.wallet_transactions (
      id, user_id, amount, type, category, reference_id, title, balance_after, created_at
    ) VALUES (
      v_tx_id, v_req.user_id, v_req.coins_awarded, 'earn', 'top_up', v_req.utr,
      'Wallet Top-up Verified (UTR: ' || v_req.utr || ')', v_new_balance, NOW()
    );

    RETURN jsonb_build_object('success', true, 'status', 'approved', 'new_balance', v_new_balance);
  ELSIF p_action = 'reject' THEN
    UPDATE public.topup_requests
    SET status = 'rejected',
        rejection_reason = p_rejection_reason,
        processed_by = auth.uid(),
        processed_at = NOW()
    WHERE id = p_request_id;

    RETURN jsonb_build_object('success', true, 'status', 'rejected');
  ELSE
    RAISE EXCEPTION 'Invalid action: %', p_action;
  END IF;
END;
$$;

-- ====================================================================
-- 6. Admin Finance RPC: Process Withdrawal Request
-- ====================================================================
CREATE OR REPLACE FUNCTION public.process_withdrawal_request(
  p_request_id VARCHAR,
  p_action VARCHAR, -- 'complete' or 'reject'
  p_rejection_reason TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_req RECORD;
  v_user RECORD;
  v_new_balance BIGINT;
  v_tx_id VARCHAR;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Admin authorization required';
  END IF;

  SELECT * INTO v_req FROM public.withdrawal_requests WHERE id = p_request_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Withdrawal request not found';
  END IF;

  IF v_req.status <> 'pending' THEN
    RAISE EXCEPTION 'Request has already been processed';
  END IF;

  IF p_action = 'complete' THEN
    UPDATE public.withdrawal_requests
    SET status = 'completed',
        processed_by = auth.uid(),
        processed_at = NOW()
    WHERE id = p_request_id;

    RETURN jsonb_build_object('success', true, 'status', 'completed');
  ELSIF p_action = 'reject' THEN
    -- Refund coins back to user balance
    SELECT * INTO v_user FROM public.profiles WHERE id = v_req.user_id FOR UPDATE;
    v_new_balance := v_user.coins + v_req.coins_deducted;

    UPDATE public.profiles
    SET coins = v_new_balance,
        updated_at = NOW()
    WHERE id = v_req.user_id;

    UPDATE public.withdrawal_requests
    SET status = 'rejected',
        rejection_reason = p_rejection_reason,
        processed_by = auth.uid(),
        processed_at = NOW()
    WHERE id = p_request_id;

    v_tx_id := 'TX_REFUND_WITHDRAW_' || SUBSTRING(p_request_id, 1, 8) || '_' || EXTRACT(EPOCH FROM NOW())::BIGINT;
    INSERT INTO public.wallet_transactions (
      id, user_id, amount, type, category, reference_id, title, balance_after, created_at
    ) VALUES (
      v_tx_id, v_req.user_id, v_req.coins_deducted, 'earn', 'reward', p_request_id,
      'Withdrawal Refunded: ' || COALESCE(p_rejection_reason, 'Rejected by Admin'), v_new_balance, NOW()
    );

    RETURN jsonb_build_object('success', true, 'status', 'rejected', 'refunded_coins', v_req.coins_deducted);
  ELSE
    RAISE EXCEPTION 'Invalid action: %', p_action;
  END IF;
END;
$$;

-- ====================================================================
-- 7. Admin Balance Adjustment Tool
-- ====================================================================
CREATE OR REPLACE FUNCTION public.admin_adjust_balance(
  p_user_id UUID,
  p_amount BIGINT,
  p_reason TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user RECORD;
  v_new_balance BIGINT;
  v_tx_id VARCHAR;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Admin authorization required';
  END IF;

  SELECT * INTO v_user FROM public.profiles WHERE id = p_user_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'User profile not found';
  END IF;

  v_new_balance := v_user.coins + p_amount;
  IF v_new_balance < 0 THEN
    RAISE EXCEPTION 'Adjustment would result in negative balance';
  END IF;

  UPDATE public.profiles
  SET coins = v_new_balance,
      updated_at = NOW()
  WHERE id = p_user_id;

  v_tx_id := 'TX_ADMIN_' || EXTRACT(EPOCH FROM NOW())::BIGINT;
  INSERT INTO public.wallet_transactions (
    id, user_id, amount, type, category, title, balance_after, created_at
  ) VALUES (
    v_tx_id, p_user_id, p_amount,
    CASE WHEN p_amount >= 0 THEN 'earn' ELSE 'spend' END,
    'admin_credit',
    'Admin Balance Adjustment: ' || p_reason,
    v_new_balance,
    NOW()
  );

  RETURN jsonb_build_object('success', true, 'new_balance', v_new_balance);
END;
$$;
