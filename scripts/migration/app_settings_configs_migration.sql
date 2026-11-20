-- ====================================================================
-- RANK EARN: APP CONFIGURATIONS & SYSTEM SETTINGS MIGRATION
-- Table: public.app_configs (Key-Value JSONB document store)
-- ====================================================================

-- 1. Create app_configs table if not exists
CREATE TABLE IF NOT EXISTS public.app_configs (
  key VARCHAR(64) PRIMARY KEY,
  value JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 2. Enable Row Level Security
ALTER TABLE public.app_configs ENABLE ROW LEVEL SECURITY;

-- 3. RLS Policies
-- Allow anyone (authenticated and anon) to read configurations (needed for app branding, maintenance mode, etc.)
DROP POLICY IF EXISTS "Authenticated users can read app configs" ON public.app_configs;
DROP POLICY IF EXISTS "Public can read app configs" ON public.app_configs;
CREATE POLICY "Public can read app configs"
  ON public.app_configs FOR SELECT
  TO authenticated, anon
  USING (true);

-- Allow admins / authenticated dashboard users to manage configurations
DROP POLICY IF EXISTS "Admins can manage app configs" ON public.app_configs;
CREATE POLICY "Admins can manage app configs"
  ON public.app_configs FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

-- 4. Seed Canonical Production Settings (idempotent, won't overwrite existing if already modified)
INSERT INTO public.app_configs (key, value) VALUES
  ('platform_info', '{
    "name": "Rankearn",
    "tagline": "India''s 1st Learning with Earning Platform",
    "email": "support@rankearn.app",
    "whatsapp": "+91 9876543210"
  }'::jsonb),
  ('feature_flags', '{
    "1v1_battle": true,
    "multiplayer_battle": true,
    "live_quiz": true,
    "mock_test_series": true,
    "fortune_wheel": true,
    "referral_earn": true,
    "live_poll": true,
    "community": true
  }'::jsonb),
  ('rewards_settings', '{
    "signup_bonus": "100",
    "referral_reward": "10",
    "battle_reward": "50",
    "spin_min": "5",
    "spin_max": "50",
    "min_withdrawal": "1000",
    "coin_rate": "100 Coins = ₹1"
  }'::jsonb),
  ('battle_settings', '{
    "question_time": "10Seconds",
    "battle_duration": "2Minutes",
    "max_players": "100",
    "entry_fee": "10 Coins",
    "winning_reward": "50 Coins"
  }'::jsonb),
  ('payment_settings', '{
    "enable_payments": true,
    "default_gateway": "Razorpay",
    "enable_razorpay": true,
    "enable_cashfree": true,
    "enable_payu": false,
    "upiId": "rankearn@upi",
    "merchantName": "Rankearn Official",
    "qrNote": "Enter exact amount and copy 12-digit UTR below",
    "coinsPerRupee": 20,
    "isLiveMode": true,
    "enable_upi_direct": true,
    "auto_refund_cancelled": true,
    "razorpayKeyId": ""
  }'::jsonb),
  ('notification_settings', '{
    "enable_push": true,
    "enable_in_app": true,
    "enable_email": false,
    "enable_sms": false
  }'::jsonb),
  ('limits_rules', '{
    "battle_limit": "20",
    "coin_limit": "1000",
    "withdrawal_limit": "5000",
    "suspension_threshold": "3 Violations"
  }'::jsonb),
  ('appearance_branding', '{
    "primary_color": "#7C3AED",
    "secondary_color": "#A855F7",
    "logo_url": "",
    "favicon_url": ""
  }'::jsonb),
  ('advanced_settings', '{
    "maintenance_mode": false,
    "debug_mode": false,
    "auto_backup": true,
    "activity_logs": true,
    "worker_url": "https://testkarlo.alleduupdated.workers.dev"
  }'::jsonb)
ON CONFLICT (key) DO NOTHING;

-- 5. Add app_configs to Realtime publication if available
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.app_configs;
  END IF;
EXCEPTION
  WHEN duplicate_object THEN NULL;
  WHEN OTHERS THEN NULL;
END $$;
