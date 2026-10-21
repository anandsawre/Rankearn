-- ==============================================================================
-- Rankearn Admin Panel: Payments Management Migration Script
-- Version: 1.0.0
-- Description: Creates payments, refunds, subscriptions, and payout settlement tables,
--              sets up RLS security policies, performance indexes, and seed data.
-- ==============================================================================

-- 1. PAYMENTS TABLE
CREATE TABLE IF NOT EXISTS public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    user_name VARCHAR(255) NOT NULL,
    user_email VARCHAR(255) NOT NULL,
    purpose VARCHAR(50) NOT NULL CHECK (purpose IN ('testSeries', 'liveQuiz', 'tournament', 'subscription')),
    amount NUMERIC(12, 2) NOT NULL CHECK (amount >= 0),
    currency VARCHAR(10) DEFAULT 'INR',
    payment_method VARCHAR(50) NOT NULL CHECK (payment_method IN ('razorpay', 'upi', 'creditCard', 'debitCard', 'netBanking', 'wallet', 'others')),
    transaction_id VARCHAR(100) UNIQUE NOT NULL,
    order_id VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending' CHECK (status IN ('success', 'failed', 'pending', 'refunded', 'partiallyRefunded')),
    gateway_ref VARCHAR(255),
    refund_amount NUMERIC(12, 2) DEFAULT 0,
    refund_reason TEXT,
    refund_date TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. REFUND AUDIT LOG TABLE
CREATE TABLE IF NOT EXISTS public.payment_refunds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    payment_id UUID NOT NULL REFERENCES public.payments(id) ON DELETE CASCADE,
    refund_amount NUMERIC(12, 2) NOT NULL CHECK (refund_amount > 0),
    refund_reason TEXT NOT NULL,
    processed_by UUID REFERENCES auth.users(id),
    gateway_refund_id VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'completed' CHECK (status IN ('pending', 'completed', 'failed')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. SUBSCRIPTIONS TABLE
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    user_name VARCHAR(255) NOT NULL,
    plan_tier VARCHAR(100) NOT NULL,
    billing_cycle VARCHAR(50) NOT NULL CHECK (billing_cycle IN ('monthly', 'quarterly', 'annual')),
    price NUMERIC(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'paused', 'cancelled', 'expired')),
    current_period_start TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    current_period_end TIMESTAMPTZ NOT NULL,
    auto_renew BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. PAYOUT SETTLEMENTS TABLE
CREATE TABLE IF NOT EXISTS public.payout_settlements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    settlement_reference VARCHAR(100) UNIQUE NOT NULL,
    gateway_provider VARCHAR(100) NOT NULL,
    gross_volume NUMERIC(12, 2) NOT NULL,
    refunds_deducted NUMERIC(12, 2) NOT NULL DEFAULT 0,
    fees_and_taxes NUMERIC(12, 2) NOT NULL DEFAULT 0,
    net_payout NUMERIC(12, 2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'settled' CHECK (status IN ('processing', 'settled', 'failed')),
    settlement_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. PERFORMANCE INDEXES
CREATE INDEX IF NOT EXISTS idx_payments_status ON public.payments(status);
CREATE INDEX IF NOT EXISTS idx_payments_purpose ON public.payments(purpose);
CREATE INDEX IF NOT EXISTS idx_payments_method ON public.payments(payment_method);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON public.payments(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON public.payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_tx_id ON public.payments(transaction_id);

-- 6. ROW LEVEL SECURITY (RLS) POLICIES
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_refunds ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payout_settlements ENABLE ROW LEVEL SECURITY;

-- Admins can view and manage all payments
CREATE POLICY "Admins have full access to payments"
    ON public.payments
    FOR ALL
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE users.id = auth.uid()
            AND (users.role = 'admin' OR users.role = 'super_admin')
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.users
            WHERE users.id = auth.uid()
            AND (users.role = 'admin' OR users.role = 'super_admin')
        )
    );

-- Users can view their own payment transactions
CREATE POLICY "Users can view own payments"
    ON public.payments
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- 7. SEED DATA (Matching Rankearn Reference Design)
INSERT INTO public.payments (
    user_name, user_email, purpose, amount, payment_method, transaction_id, order_id, status, gateway_ref, created_at
) VALUES
    ('Rahul Sharma', 'rahul.sharma@example.com', 'testSeries', 199.00, 'razorpay', 'pay_7H3kLm92', 'ord_9842104', 'success', 'rzp_capt_789123', '2026-10-18 10:24:00+05:30'),
    ('Priya Verma', 'priya.verma@example.com', 'liveQuiz', 49.00, 'upi', 'upi_8J9nPq33', 'ord_9842105', 'success', 'upi_ref_441299', '2026-10-18 09:12:00+05:30'),
    ('Amit Kumar', 'amit.kumar@example.com', 'tournament', 299.00, 'creditCard', 'card_9X2mKp11', 'ord_9842106', 'success', 'hdfc_pg_662310', '2026-10-17 20:45:00+05:30'),
    ('Neha Singh', 'neha.singh@example.com', 'subscription', 499.00, 'netBanking', 'nb_2LmNq88', 'ord_9842107', 'success', 'sbi_nb_990142', '2026-10-17 18:30:00+05:30'),
    ('Vikash Yadav', 'vikash.yadav@example.com', 'testSeries', 149.00, 'upi', 'upi_6K8pZj22', 'ord_9842108', 'failed', 'upi_fail_timeout', '2026-10-16 17:20:00+05:30'),
    ('Anjali Patel', 'anjali.patel@example.com', 'tournament', 299.00, 'wallet', 'wal_4MNQx77', 'ord_9842109', 'success', 'paytm_wal_88231', '2026-10-16 16:10:00+05:30'),
    ('Saurabh Gupta', 'saurabh.gupta@example.com', 'liveQuiz', 99.00, 'debitCard', 'card_3LpNW55', 'ord_9842110', 'pending', 'axis_deb_awaiting_webhook', '2026-10-15 14:15:00+05:30')
ON CONFLICT (transaction_id) DO NOTHING;
