-- ==============================================================================
-- Rankearn Lucky Wheel Management System Migration
-- Secure Spin & Reward Engine, Auditable Ledger, RLS, Indexes & Reference Seeds
-- ==============================================================================

-- 1. CAMPAIGNS TABLE
CREATE TABLE IF NOT EXISTS public.lucky_wheel_campaigns (
    id TEXT PRIMARY KEY DEFAULT ('wheel-camp-' || gen_random_uuid()),
    title TEXT NOT NULL,
    subtitle TEXT NOT NULL,
    reward_type TEXT NOT NULL DEFAULT 'coins' CHECK (reward_type IN ('coins', 'cashback', 'discount', 'gift', 'product', 'noPrize')),
    start_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    end_date TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '14 days'),
    total_spins INTEGER NOT NULL DEFAULT 0,
    participants INTEGER NOT NULL DEFAULT 0,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'scheduled', 'completed', 'paused', 'draft')),
    created_by TEXT NOT NULL DEFAULT 'Admin',
    spin_cost INTEGER NOT NULL DEFAULT 10,
    daily_limit INTEGER NOT NULL DEFAULT 5,
    campaign_limit INTEGER NOT NULL DEFAULT 10,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. REWARD SEGMENTS (SLICES) TABLE
CREATE TABLE IF NOT EXISTS public.lucky_wheel_reward_slices (
    id TEXT PRIMARY KEY DEFAULT ('slice-' || gen_random_uuid()),
    campaign_id TEXT NOT NULL REFERENCES public.lucky_wheel_campaigns(id) ON DELETE CASCADE,
    label TEXT NOT NULL,
    reward_type TEXT NOT NULL DEFAULT 'coins',
    reward_value INTEGER NOT NULL DEFAULT 0,
    probability INTEGER NOT NULL DEFAULT 10 CHECK (probability >= 0 AND probability <= 100),
    slice_color BIGINT NOT NULL DEFAULT 4283838205, -- ARGB32
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. AUTHORITATIVE SPIN RECORDS & AUDIT LEDGER TABLE
CREATE TABLE IF NOT EXISTS public.lucky_wheel_spins (
    id TEXT PRIMARY KEY DEFAULT ('spin-' || gen_random_uuid()),
    campaign_id TEXT NOT NULL REFERENCES public.lucky_wheel_campaigns(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    slice_id TEXT REFERENCES public.lucky_wheel_reward_slices(id),
    reward_label TEXT NOT NULL,
    reward_type TEXT NOT NULL,
    reward_value INTEGER NOT NULL DEFAULT 0,
    spin_cost_paid INTEGER NOT NULL DEFAULT 10,
    status TEXT NOT NULL DEFAULT 'credited' CHECK (status IN ('credited', 'issued', 'pending', 'completed', 'failed')),
    transaction_id TEXT NOT NULL UNIQUE DEFAULT ('TXN-' || gen_random_uuid()),
    idempotency_key TEXT UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. INDEXES FOR HIGH-CONCURRENCY QUERY PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_lucky_wheel_campaigns_status ON public.lucky_wheel_campaigns(status);
CREATE INDEX IF NOT EXISTS idx_lucky_wheel_campaigns_dates ON public.lucky_wheel_campaigns(start_date, end_date);
CREATE INDEX IF NOT EXISTS idx_lucky_wheel_slices_campaign ON public.lucky_wheel_reward_slices(campaign_id);
CREATE INDEX IF NOT EXISTS idx_lucky_wheel_spins_campaign_user ON public.lucky_wheel_spins(campaign_id, user_id);
CREATE INDEX IF NOT EXISTS idx_lucky_wheel_spins_created ON public.lucky_wheel_spins(created_at DESC);

-- 5. ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE public.lucky_wheel_campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lucky_wheel_reward_slices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lucky_wheel_spins ENABLE ROW LEVEL SECURITY;

-- Campaigns: Everyone can view active campaigns; Admins can do full CRUD
CREATE POLICY "Public read active campaigns"
    ON public.lucky_wheel_campaigns FOR SELECT
    USING (status = 'active' OR auth.role() = 'authenticated');

CREATE POLICY "Admin full manage campaigns"
    ON public.lucky_wheel_campaigns FOR ALL
    USING (auth.jwt() ->> 'role' = 'admin' OR auth.jwt() ->> 'email' LIKE '%admin%');

-- Reward slices: Readable by authenticated users; Admin managed
CREATE POLICY "Public read slices"
    ON public.lucky_wheel_reward_slices FOR SELECT
    USING (true);

CREATE POLICY "Admin manage slices"
    ON public.lucky_wheel_reward_slices FOR ALL
    USING (auth.jwt() ->> 'role' = 'admin' OR auth.jwt() ->> 'email' LIKE '%admin%');

-- Spin records: Users can view their own spins; Admins can view all
CREATE POLICY "Users view own spins"
    ON public.lucky_wheel_spins FOR SELECT
    USING (auth.uid() = user_id OR auth.jwt() ->> 'role' = 'admin');

-- 6. SECURE SERVER-SIDE SPIN ENGINE RPC (NO CLIENT AUTHORITY)
CREATE OR REPLACE FUNCTION public.fn_spin_lucky_wheel(
    p_campaign_id TEXT,
    p_idempotency_key TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID;
    v_user_email TEXT;
    v_user_name TEXT;
    v_campaign RECORD;
    v_daily_spins_count INTEGER;
    v_total_spins_count INTEGER;
    v_selected_slice RECORD;
    v_rand_val NUMERIC;
    v_cumulative NUMERIC := 0;
    v_spin_id TEXT;
    v_txn_id TEXT;
    v_existing_spin RECORD;
BEGIN
    -- 1. Verify User Authentication
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required to spin the wheel.';
    END IF;

    -- 2. Idempotency Check (prevent duplicate requests/spins on network retries)
    IF p_idempotency_key IS NOT NULL THEN
        SELECT * INTO v_existing_spin FROM public.lucky_wheel_spins
        WHERE idempotency_key = p_idempotency_key;
        IF FOUND THEN
            RETURN jsonb_build_object(
                'status', 'success',
                'spin_id', v_existing_spin.id,
                'reward_label', v_existing_spin.reward_label,
                'reward_type', v_existing_spin.reward_type,
                'reward_value', v_existing_spin.reward_value,
                'transaction_id', v_existing_spin.transaction_id,
                'is_idempotent_replay', true
            );
        END IF;
    END IF;

    -- 3. Lock and Verify Campaign Eligibility
    SELECT * INTO v_campaign FROM public.lucky_wheel_campaigns
    WHERE id = p_campaign_id FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Campaign not found.';
    END IF;

    IF v_campaign.status != 'active' THEN
        RAISE EXCEPTION 'Campaign is not currently active.';
    END IF;

    IF NOW() < v_campaign.start_date OR NOW() > v_campaign.end_date THEN
        RAISE EXCEPTION 'Campaign is outside the permitted active time window.';
    END IF;

    -- 4. Check User Spin Limits (Daily and Total)
    SELECT COUNT(*) INTO v_daily_spins_count
    FROM public.lucky_wheel_spins
    WHERE campaign_id = p_campaign_id
      AND user_id = v_user_id
      AND created_at >= CURRENT_DATE;

    IF v_daily_spins_count >= v_campaign.daily_limit THEN
        RAISE EXCEPTION 'Daily spin limit of % reached for this campaign.', v_campaign.daily_limit;
    END IF;

    SELECT COUNT(*) INTO v_total_spins_count
    FROM public.lucky_wheel_spins
    WHERE campaign_id = p_campaign_id
      AND user_id = v_user_id;

    IF v_total_spins_count >= v_campaign.campaign_limit THEN
        RAISE EXCEPTION 'Campaign maximum spin limit of % reached.', v_campaign.campaign_limit;
    END IF;

    -- 5. Secure Random Wheel Slice Selection based on configured probability weights
    v_rand_val := random() * 100.0;
    FOR v_selected_slice IN
        SELECT * FROM public.lucky_wheel_reward_slices
        WHERE campaign_id = p_campaign_id AND is_active = true
        ORDER BY id
    LOOP
        v_cumulative := v_cumulative + v_selected_slice.probability;
        IF v_rand_val <= v_cumulative THEN
            EXIT;
        END IF;
    END LOOP;

    -- Fallback safety slice if none hit
    IF v_selected_slice IS NULL THEN
        SELECT * INTO v_selected_slice FROM public.lucky_wheel_reward_slices
        WHERE campaign_id = p_campaign_id AND is_active = true
        LIMIT 1;
    END IF;

    -- 6. Generate Authoritative Spin & Ledger Records
    v_spin_id := 'spin-' || gen_random_uuid();
    v_txn_id := 'TXN-WHEEL-' || gen_random_uuid();

    SELECT COALESCE(raw_user_meta_data->>'full_name', email) INTO v_user_name
    FROM auth.users WHERE id = v_user_id;

    INSERT INTO public.lucky_wheel_spins (
        id,
        campaign_id,
        user_id,
        user_name,
        slice_id,
        reward_label,
        reward_type,
        reward_value,
        spin_cost_paid,
        status,
        transaction_id,
        idempotency_key
    ) VALUES (
        v_spin_id,
        p_campaign_id,
        v_user_id,
        COALESCE(v_user_name, 'Participant'),
        v_selected_slice.id,
        v_selected_slice.label,
        v_selected_slice.reward_type,
        v_selected_slice.reward_value,
        v_campaign.spin_cost,
        'credited',
        v_txn_id,
        p_idempotency_key
    );

    -- 7. Atomically Update Campaign Counters
    UPDATE public.lucky_wheel_campaigns
    SET total_spins = total_spins + 1,
        participants = (
            SELECT COUNT(DISTINCT user_id)
            FROM public.lucky_wheel_spins
            WHERE campaign_id = p_campaign_id
        ),
        updated_at = NOW()
    WHERE id = p_campaign_id;

    -- 8. Return Authoritative Result
    RETURN jsonb_build_object(
        'status', 'success',
        'spin_id', v_spin_id,
        'slice_id', v_selected_slice.id,
        'reward_label', v_selected_slice.label,
        'reward_type', v_selected_slice.reward_type,
        'reward_value', v_selected_slice.reward_value,
        'transaction_id', v_txn_id,
        'remaining_daily_spins', (v_campaign.daily_limit - v_daily_spins_count - 1)
    );
END;
$$;

-- 7. SEED DATA (7 Primary Reference Campaigns)
INSERT INTO public.lucky_wheel_campaigns (id, title, subtitle, reward_type, start_date, end_date, total_spins, participants, status, created_by, spin_cost, daily_limit)
VALUES
('wheel-camp-001', 'Daily Spin Rewards', 'Win coins, cashback and more', 'coins', '2026-10-18 10:00:00+00', '2026-10-31 23:59:00+00', 12450, 5240, 'active', 'Admin', 10, 5),
('wheel-camp-002', 'Festive Mega Spin', 'Special rewards for festival', 'cashback', '2026-10-15 09:00:00+00', '2026-10-30 23:59:00+00', 18230, 6820, 'active', 'Admin', 15, 5),
('wheel-camp-003', 'New User Bonus Spin', 'Exclusive for new users', 'gift', '2026-10-10 00:00:00+00', '2026-12-31 23:59:00+00', 8450, 4120, 'scheduled', 'Admin', 0, 5),
('wheel-camp-004', 'Weekend Lucky Draw', 'Spin and win big rewards', 'discount', '2026-10-08 10:00:00+00', '2026-10-12 23:59:00+00', 6780, 2940, 'completed', 'Admin', 20, 5),
('wheel-camp-005', 'Exam Prep Spin', 'Special rewards for students', 'coins', '2026-10-05 10:00:00+00', '2026-10-25 23:59:00+00', 14320, 5680, 'completed', 'Admin', 10, 5),
('wheel-camp-006', 'Mega Reward Spin', 'High value rewards campaign', 'product', '2026-10-01 10:00:00+00', '2026-10-20 23:59:00+00', 9450, 3860, 'active', 'Admin', 25, 5),
('wheel-camp-007', 'Referral Spin', 'Spin for referring friends', 'cashback', '2026-09-28 10:00:00+00', '2026-10-15 23:59:00+00', 8640, 3120, 'paused', 'Admin', 10, 5)
ON CONFLICT (id) DO UPDATE SET daily_limit = EXCLUDED.daily_limit;

-- Ensure all existing active campaigns adhere to daily limit = 5
UPDATE public.lucky_wheel_campaigns SET daily_limit = 5 WHERE daily_limit = 3;

-- Seed Slices for Daily Spin Rewards (Canonical 8 Slices summing to 100%)
INSERT INTO public.lucky_wheel_reward_slices (campaign_id, label, reward_type, reward_value, probability, slice_color, is_active)
VALUES
('wheel-camp-001', '100 Coins', 'coins', 100, 17, 4294319627, true),
('wheel-camp-001', '50 Coins', 'coins', 50, 25, 4279318913, true),
('wheel-camp-001', 'Rank Booster', 'gift', 0, 5, 4292507398, true),
('wheel-camp-001', 'Surprise Gift', 'gift', 150, 3, 4294197086, true),
('wheel-camp-001', '10 Coins', 'coins', 10, 30, 4294319627, true),
('wheel-camp-001', '500 Coins', 'coins', 500, 2, 4293862468, true),
('wheel-camp-001', '200 Coins', 'coins', 200, 10, 4287324150, true),
('wheel-camp-001', 'Extra Attempt', 'gift', 0, 8, 4278416583, true)
ON CONFLICT DO NOTHING;
