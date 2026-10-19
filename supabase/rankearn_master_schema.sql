-- ====================================================================
-- RANKEARN SUPABASE MASTER PRODUCTION SCHEMA (COPY-PASTE READY)
-- Generated for Supabase SQL Editor
-- Includes: All 24 Tables, Indexes, RLS Policies, Triggers, RPCs & Seed
-- ====================================================================

-- ====================================================================
-- RANK EARN SUPABASE SCHEMA MIGRATION 001: INITIAL APPLICATION SCHEMA
-- ====================================================================

-- 1. App Roles Enum
CREATE TYPE public.app_role AS ENUM ('user', 'support', 'admin');

-- 2. Profiles (1:1 with auth.users)
CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  legacy_firebase_uid VARCHAR(128) UNIQUE,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  profile_photo_url TEXT,
  exam_preparing_for VARCHAR(100),
  state VARCHAR(100),
  coins BIGINT NOT NULL DEFAULT 0 CHECK (coins >= 0),
  total_earned BIGINT NOT NULL DEFAULT 0,
  total_spent BIGINT NOT NULL DEFAULT 0,
  withdrawable_balance NUMERIC(12, 2) NOT NULL DEFAULT 0.00 CHECK (withdrawable_balance >= 0),
  badges TEXT[] DEFAULT '{}',
  subscription_status VARCHAR(20) NOT NULL DEFAULT 'free' CHECK (subscription_status IN ('free', 'premium')),
  subscription_end_date TIMESTAMPTZ,
  is_leaderboard_eligible BOOLEAN DEFAULT false,
  last_spin_date TIMESTAMPTZ,
  saved_payment_details JSONB DEFAULT '{}'::jsonb,
  referred_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  referral_code VARCHAR(16) UNIQUE,
  status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'banned')),
  ban_reason TEXT,
  ban_until TIMESTAMPTZ,
  violation_count INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

CREATE INDEX idx_profiles_email ON public.profiles(email);
CREATE INDEX idx_profiles_referral_code ON public.profiles(referral_code);
CREATE INDEX idx_profiles_referred_by ON public.profiles(referred_by);

-- 3. Dedicated User Roles Table (Protected server-side role store)
CREATE TABLE public.user_roles (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role public.app_role NOT NULL DEFAULT 'user',
  granted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  granted_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
  UNIQUE (user_id, role)
);
CREATE INDEX idx_user_roles_user_id ON public.user_roles(user_id);

-- 4. Exam Categories (SSC, BPSC, UPSC, Banking, etc.)
CREATE TABLE public.exam_categories (
  id VARCHAR(64) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  normalized_name VARCHAR(100),
  icon_url TEXT,
  languages VARCHAR(50) DEFAULT 'en,hi',
  is_published BOOLEAN DEFAULT true,
  display_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 5. Categories / Subjects (Mathematics, General Knowledge, History, etc.)
CREATE TABLE public.categories (
  id VARCHAR(64) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  exam_category_id VARCHAR(64) REFERENCES public.exam_categories(id) ON DELETE CASCADE,
  topics TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);
CREATE INDEX idx_categories_exam ON public.categories(exam_category_id);

-- 6. Exam Patterns (Blueprints for AI Test Generation)
CREATE TABLE public.exam_patterns (
  id VARCHAR(64) PRIMARY KEY,
  exam_name VARCHAR(100) NOT NULL,
  category VARCHAR(100) NOT NULL,
  sections JSONB NOT NULL DEFAULT '[]'::jsonb, -- Array of { subject, questionCount, topics }
  total_duration INT NOT NULL CHECK (total_duration > 0),
  negative_marking NUMERIC(4, 2) NOT NULL DEFAULT 0.00,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 7. Tests (Test Series & Tournaments)
CREATE TABLE public.tests (
  id VARCHAR(64) PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  exam_category_id VARCHAR(64) REFERENCES public.exam_categories(id) ON DELETE SET NULL,
  category_id VARCHAR(64) REFERENCES public.categories(id) ON DELETE SET NULL,
  test_mode VARCHAR(30) NOT NULL DEFAULT 'mock' CHECK (test_mode IN ('mock', 'sectional', 'previous-year', 'tournament')),
  duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
  total_questions INT NOT NULL DEFAULT 0,
  negative_marking NUMERIC(4, 2) NOT NULL DEFAULT 0.00,
  is_premium BOOLEAN NOT NULL DEFAULT false,
  is_pro_only BOOLEAN NOT NULL DEFAULT false,
  unlock_price_coins INT DEFAULT 0,
  status VARCHAR(20) NOT NULL DEFAULT 'published' CHECK (status IN ('published', 'unpublished', 'draft')),
  is_tournament BOOLEAN NOT NULL DEFAULT false,
  entry_fee_coins INT DEFAULT 0,
  admin_commission_pct INT DEFAULT 10,
  prize_distribution JSONB DEFAULT '[]'::jsonb,
  scheduled_start_time TIMESTAMPTZ,
  scheduled_end_time TIMESTAMPTZ,
  total_participants INT NOT NULL DEFAULT 0,
  max_participants INT DEFAULT 1000,
  is_result_declared BOOLEAN DEFAULT false,
  syllabus TEXT,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);
CREATE INDEX idx_tests_mode ON public.tests(test_mode, status);
CREATE INDEX idx_tests_tournament ON public.tests(is_tournament, scheduled_start_time, scheduled_end_time);

-- 8. Questions
CREATE TABLE public.questions (
  id VARCHAR(64) PRIMARY KEY,
  test_id VARCHAR(64) NOT NULL REFERENCES public.tests(id) ON DELETE CASCADE,
  question_number INT NOT NULL,
  question_text_english TEXT NOT NULL,
  question_text_hindi TEXT,
  options JSONB NOT NULL, -- Array of { textEnglish, textHindi, image }
  correct_answer INT NOT NULL CHECK (correct_answer BETWEEN 0 AND 3),
  explanation_english TEXT,
  explanation_hindi TEXT,
  difficulty_level VARCHAR(20) DEFAULT 'medium' CHECK (difficulty_level IN ('easy', 'medium', 'hard')),
  subject VARCHAR(100),
  topic VARCHAR(100),
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);
CREATE INDEX idx_questions_test_id ON public.questions(test_id, question_number);

-- 9. Tournament Participants
CREATE TABLE public.tournament_participants (
  id BIGSERIAL PRIMARY KEY,
  test_id VARCHAR(64) NOT NULL REFERENCES public.tests(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  fee_paid INT NOT NULL DEFAULT 0,
  joined_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
  UNIQUE (test_id, user_id)
);
CREATE INDEX idx_tournament_participants_user ON public.tournament_participants(user_id);

-- 10. Unlocked Tests (Permanent coin unlocks)
CREATE TABLE public.unlocked_tests (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  test_id VARCHAR(64) NOT NULL REFERENCES public.tests(id) ON DELETE CASCADE,
  coins_paid INT NOT NULL DEFAULT 0,
  unlocked_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
  UNIQUE (user_id, test_id)
);
CREATE INDEX idx_unlocked_tests_user ON public.unlocked_tests(user_id);

-- 11. Attempts (Quiz Attempts & Results)
CREATE TABLE public.attempts (
  id VARCHAR(64) PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  test_id VARCHAR(64) NOT NULL REFERENCES public.tests(id) ON DELETE CASCADE,
  answers JSONB NOT NULL DEFAULT '{}'::jsonb, -- questionId -> selectedOptionIndex
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  time_taken_seconds INT NOT NULL CHECK (time_taken_seconds >= 0),
  score NUMERIC(6, 2) NOT NULL,
  accuracy NUMERIC(5, 2) NOT NULL,
  rank INT,
  is_tournament BOOLEAN DEFAULT false,
  coins_earned INT DEFAULT 0,
  is_coins_awarded BOOLEAN DEFAULT false,
  tournament_rank INT,
  status VARCHAR(20) DEFAULT 'completed',
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);
CREATE INDEX idx_attempts_user ON public.attempts(user_id, created_at DESC);
CREATE INDEX idx_attempts_test_score ON public.attempts(test_id, score DESC, time_taken_seconds ASC);

-- 12. Wallet Transactions (Append-Only Ledger)
CREATE TABLE public.wallet_transactions (
  id VARCHAR(64) PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  amount BIGINT NOT NULL CHECK (amount <> 0),
  type VARCHAR(10) NOT NULL CHECK (type IN ('earn', 'spend')),
  category VARCHAR(40) NOT NULL CHECK (category IN (
    'top_up', 'tournament_entry', 'tournament_prize', 'reward', 'admin_credit',
    'referral', 'spin_wheel', 'unlock_test', 'withdrawal', 'battle_win', 'battle_refund'
  )),
  reference_id VARCHAR(64),
  title TEXT NOT NULL,
  balance_after BIGINT NOT NULL CHECK (balance_after >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);
CREATE INDEX idx_wallet_tx_user ON public.wallet_transactions(user_id, created_at DESC);

-- 13. Top-Up Requests (Manual UPI verification)
CREATE TABLE public.topup_requests (
  id VARCHAR(64) PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
  coins_awarded BIGINT NOT NULL CHECK (coins_awarded > 0),
  utr VARCHAR(64) NOT NULL UNIQUE,
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  user_name VARCHAR(100),
  user_email VARCHAR(255),
  user_phone VARCHAR(20),
  user_photo_url TEXT,
  rejection_reason TEXT,
  processed_by UUID REFERENCES auth.users(id),
  processed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);
CREATE INDEX idx_topup_status ON public.topup_requests(status, created_at DESC);

-- 14. Withdrawal Requests
CREATE TABLE public.withdrawal_requests (
  id VARCHAR(64) PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  coins_deducted BIGINT NOT NULL CHECK (coins_deducted > 0),
  payout_amount NUMERIC(10, 2) NOT NULL CHECK (payout_amount > 0),
  method VARCHAR(10) NOT NULL CHECK (method IN ('upi', 'bank')),
  upi_id VARCHAR(100),
  bank_details JSONB DEFAULT '{}'::jsonb,
  status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'rejected')),
  rejection_reason TEXT,
  processed_by UUID REFERENCES auth.users(id),
  processed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);
CREATE INDEX idx_withdraw_status ON public.withdrawal_requests(status, created_at DESC);

-- 15. App Banners
CREATE TABLE public.app_banners (
  id VARCHAR(64) PRIMARY KEY,
  image_url TEXT NOT NULL,
  title VARCHAR(255),
  link TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  priority INT NOT NULL DEFAULT 0,
  type VARCHAR(20) DEFAULT 'image',
  spotlight_data JSONB,
  scheduled_at TIMESTAMPTZ,
  clicks BIGINT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);
CREATE INDEX idx_app_banners_active ON public.app_banners(is_active, priority DESC);

-- 16. Posts & Current Affairs (Rich Text Announcements)
CREATE TABLE public.posts (
  id VARCHAR(64) PRIMARY KEY,
  slug VARCHAR(255) NOT NULL UNIQUE,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  excerpt TEXT,
  image_url TEXT,
  category VARCHAR(100) DEFAULT 'general',
  author_name VARCHAR(100) NOT NULL DEFAULT 'Rankearn Team',
  is_active BOOLEAN NOT NULL DEFAULT true,
  meta_title VARCHAR(255),
  meta_description TEXT,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);
CREATE INDEX idx_posts_active ON public.posts(is_active, created_at DESC);

-- 17. Community Polls & Poll Votes
CREATE TABLE public.polls (
  id VARCHAR(64) PRIMARY KEY,
  question TEXT NOT NULL,
  options JSONB NOT NULL DEFAULT '[]'::jsonb, -- Array of strings
  votes JSONB NOT NULL DEFAULT '{}'::jsonb,   -- optionIndex -> count
  target_segment VARCHAR(20) NOT NULL DEFAULT 'all' CHECK (target_segment IN ('all', 'pro', 'free')),
  is_active BOOLEAN NOT NULL DEFAULT true,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

CREATE TABLE public.poll_votes (
  id BIGSERIAL PRIMARY KEY,
  poll_id VARCHAR(64) NOT NULL REFERENCES public.polls(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  option_index INT NOT NULL,
  voted_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  UNIQUE (poll_id, user_id)
);

-- 18. Battle Questions & 1v1 Battles
CREATE TABLE public.battle_questions (
  id VARCHAR(64) PRIMARY KEY,
  text_english TEXT NOT NULL,
  text_hindi TEXT,
  options_english JSONB NOT NULL,
  options_hindi JSONB,
  correct_answer INT NOT NULL CHECK (correct_answer BETWEEN 0 AND 3),
  topic VARCHAR(100),
  difficulty VARCHAR(20) DEFAULT 'medium',
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

CREATE TABLE public.battles (
  id VARCHAR(64) PRIMARY KEY,
  creator_id UUID NOT NULL REFERENCES public.profiles(id),
  opponent_id UUID REFERENCES public.profiles(id),
  entry_fee INT NOT NULL DEFAULT 10,
  status VARCHAR(20) NOT NULL DEFAULT 'waiting' CHECK (status IN ('waiting', 'active', 'completed', 'cancelled')),
  winner_id UUID REFERENCES public.profiles(id),
  creator_score INT DEFAULT 0,
  opponent_score INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  completed_at TIMESTAMPTZ
);

-- 19. Customer Support (Tickets & Messages)
CREATE TABLE public.support_tickets (
  id VARCHAR(64) PRIMARY KEY, -- Matches user_id for 1:1 support
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  user_name VARCHAR(100) NOT NULL,
  user_email VARCHAR(255) NOT NULL,
  user_photo_url TEXT,
  last_message TEXT,
  unread_count INT NOT NULL DEFAULT 0,
  status VARCHAR(20) NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'closed')),
  last_updated TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

CREATE TABLE public.support_messages (
  id VARCHAR(64) PRIMARY KEY,
  ticket_id VARCHAR(64) NOT NULL REFERENCES public.support_tickets(id) ON DELETE CASCADE,
  sender_id UUID NOT NULL REFERENCES auth.users(id),
  sender_name VARCHAR(100) NOT NULL,
  text TEXT NOT NULL,
  role VARCHAR(20) NOT NULL CHECK (role IN ('user', 'admin')),
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);
CREATE INDEX idx_support_messages_ticket ON public.support_messages(ticket_id, created_at ASC);

-- 20. Feedback & Ratings
CREATE TABLE public.feedbacks (
  id VARCHAR(64) PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  user_name VARCHAR(100) NOT NULL,
  rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 21. Notifications
CREATE TABLE public.notifications (
  id VARCHAR(64) PRIMARY KEY,
  user_id VARCHAR(64) NOT NULL, -- UUID or 'global'
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(30) NOT NULL DEFAULT 'info',
  action_url TEXT,
  image_url TEXT,
  is_read BOOLEAN NOT NULL DEFAULT false,
  read_by UUID[] DEFAULT '{}',
  target_segment VARCHAR(20) DEFAULT 'all',
  clicks BIGINT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);
CREATE INDEX idx_notifications_user ON public.notifications(user_id, created_at DESC);

-- 22. User Device Tokens (for FCM push notifications)
CREATE TABLE public.user_device_tokens (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  platform VARCHAR(20) NOT NULL DEFAULT 'android',
  last_seen_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);
CREATE INDEX idx_device_tokens_user ON public.user_device_tokens(user_id);

-- 23. App Configurations (Key-Value Config Documents)
CREATE TABLE public.app_configs (
  key VARCHAR(64) PRIMARY KEY,
  value JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 24. Migration UID Map (Private mapping table for legacy UID continuity)
CREATE TABLE public.migration_uid_map (
  firebase_uid VARCHAR(128) PRIMARY KEY,
  supabase_uid UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);


-- ====================================================================
-- RANK EARN SUPABASE SCHEMA MIGRATION 002: ROW LEVEL SECURITY POLICIES
-- ====================================================================

-- 1. Helper Security Functions (SECURITY DEFINER, STABLE, SEARCH_PATH fixed)

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = auth.uid() AND role = 'admin'
  );
$$;

REVOKE EXECUTE ON FUNCTION public.is_admin() FROM public;
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;

CREATE OR REPLACE FUNCTION public.is_active_user()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND status = 'active'
  );
$$;

REVOKE EXECUTE ON FUNCTION public.is_active_user() FROM public;
GRANT EXECUTE ON FUNCTION public.is_active_user() TO authenticated;

-- ====================================================================
-- 2. ENABLE ROW LEVEL SECURITY ON ALL APPLICATION TABLES
-- ====================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tournament_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.unlocked_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.topup_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.withdrawal_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.polls ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.poll_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.battle_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.battles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedbacks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_device_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.migration_uid_map ENABLE ROW LEVEL SECURITY;

-- ====================================================================
-- 3. TABLE-BY-TABLE POLICIES
-- ====================================================================

-- --- A. PROFILES ---
CREATE POLICY "Public profile display info"
  ON public.profiles FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Users can update own non-sensitive profile fields"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (id = auth.uid() AND public.is_active_user())
  WITH CHECK (
    id = auth.uid() AND
    -- Prevent tampering with balances, subscription, or role
    coins = (SELECT p.coins FROM public.profiles p WHERE p.id = auth.uid()) AND
    withdrawable_balance = (SELECT p.withdrawable_balance FROM public.profiles p WHERE p.id = auth.uid()) AND
    status = (SELECT p.status FROM public.profiles p WHERE p.id = auth.uid())
  );

CREATE POLICY "Admins full control on profiles"
  ON public.profiles FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- B. USER ROLES ---
CREATE POLICY "Users can view own roles"
  ON public.user_roles FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Admins can manage user roles"
  ON public.user_roles FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- C. EXAM CATEGORIES & CATEGORIES ---
CREATE POLICY "Everyone can read exam categories"
  ON public.exam_categories FOR SELECT
  TO authenticated, anon
  USING (is_published = true OR public.is_admin());

CREATE POLICY "Admins can manage exam categories"
  ON public.exam_categories FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

CREATE POLICY "Everyone can read categories"
  ON public.categories FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Admins can manage categories"
  ON public.categories FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- D. EXAM PATTERNS ---
CREATE POLICY "Authenticated users can view exam patterns"
  ON public.exam_patterns FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can manage exam patterns"
  ON public.exam_patterns FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- E. TESTS ---
CREATE POLICY "Everyone can read published tests"
  ON public.tests FOR SELECT
  TO authenticated, anon
  USING (status = 'published' OR public.is_admin());

CREATE POLICY "Admins can manage tests"
  ON public.tests FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- F. QUESTIONS ---
CREATE POLICY "Authenticated users can read test questions"
  ON public.questions FOR SELECT
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.tests t
    WHERE t.id = public.questions.test_id AND (t.status = 'published' OR public.is_admin())
  ));

CREATE POLICY "Admins can manage questions"
  ON public.questions FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- G. TOURNAMENT PARTICIPANTS ---
CREATE POLICY "Participants can view tournament list"
  ON public.tournament_participants FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins manage tournament participants"
  ON public.tournament_participants FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- H. UNLOCKED TESTS ---
CREATE POLICY "Users can view own unlocked tests"
  ON public.unlocked_tests FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR public.is_admin());

-- --- I. ATTEMPTS ---
CREATE POLICY "Users can read own attempts"
  ON public.attempts FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Admins can manage attempts"
  ON public.attempts FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- J. WALLET TRANSACTIONS (Append-only ledger, no client direct insert) ---
CREATE POLICY "Users can read own wallet transactions"
  ON public.wallet_transactions FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Admins can view all wallet transactions"
  ON public.wallet_transactions FOR SELECT
  TO authenticated
  USING (public.is_admin());

-- --- K. TOP-UP REQUESTS ---
CREATE POLICY "Users can view own top-up requests"
  ON public.topup_requests FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Users can create top-up requests"
  ON public.topup_requests FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = auth.uid() AND
    status = 'pending' AND
    amount > 0 AND
    length(utr) >= 10 AND
    public.is_active_user()
  );

CREATE POLICY "Admins can manage top-up requests"
  ON public.topup_requests FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- L. WITHDRAWAL REQUESTS ---
CREATE POLICY "Users can view own withdrawal requests"
  ON public.withdrawal_requests FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Users can create withdrawal requests"
  ON public.withdrawal_requests FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = auth.uid() AND
    status = 'pending' AND
    coins_deducted > 0 AND
    public.is_active_user()
  );

CREATE POLICY "Admins can manage withdrawal requests"
  ON public.withdrawal_requests FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- M. APP BANNERS & POSTS ---
CREATE POLICY "Everyone can read active banners"
  ON public.app_banners FOR SELECT
  TO authenticated, anon
  USING (is_active = true OR public.is_admin());

CREATE POLICY "Admins can manage banners"
  ON public.app_banners FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

CREATE POLICY "Everyone can read active posts"
  ON public.posts FOR SELECT
  TO authenticated, anon
  USING (is_active = true OR public.is_admin());

CREATE POLICY "Admins can manage posts"
  ON public.posts FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- N. POLLS & POLL VOTES ---
CREATE POLICY "Everyone can read active polls"
  ON public.polls FOR SELECT
  TO authenticated, anon
  USING (is_active = true OR public.is_admin());

CREATE POLICY "Admins can manage polls"
  ON public.polls FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

CREATE POLICY "Users can view poll votes"
  ON public.poll_votes FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Users can cast one poll vote"
  ON public.poll_votes FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid() AND public.is_active_user());

-- --- O. BATTLE QUESTIONS & BATTLES ---
CREATE POLICY "Authenticated users can read battle questions"
  ON public.battle_questions FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can manage battle questions"
  ON public.battle_questions FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

CREATE POLICY "Participants can view and update their battles"
  ON public.battles FOR ALL
  TO authenticated
  USING (creator_id = auth.uid() OR opponent_id = auth.uid() OR public.is_admin())
  WITH CHECK (creator_id = auth.uid() OR opponent_id = auth.uid() OR public.is_admin());

-- --- P. SUPPORT TICKETS & MESSAGES ---
CREATE POLICY "Users view own support ticket"
  ON public.support_tickets FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Users can create own support ticket"
  ON public.support_tickets FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users and admins can update ticket status"
  ON public.support_tickets FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Users and admins can read messages in their tickets"
  ON public.support_messages FOR SELECT
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.support_tickets t
    WHERE t.id = public.support_messages.ticket_id AND (t.user_id = auth.uid() OR public.is_admin())
  ));

CREATE POLICY "Users and admins can send messages in their tickets"
  ON public.support_messages FOR INSERT
  TO authenticated
  WITH CHECK (
    sender_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM public.support_tickets t
      WHERE t.id = ticket_id AND (t.user_id = auth.uid() OR public.is_admin())
    )
  );

-- --- Q. FEEDBACKS ---
CREATE POLICY "Admins can view feedbacks"
  ON public.feedbacks FOR SELECT
  TO authenticated
  USING (public.is_admin());

CREATE POLICY "Users can submit feedback"
  ON public.feedbacks FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- --- R. NOTIFICATIONS ---
CREATE POLICY "Users can view personal and global notifications"
  ON public.notifications FOR SELECT
  TO authenticated
  USING (user_id = auth.uid()::text OR user_id = 'global' OR public.is_admin());

CREATE POLICY "Users can mark own notifications as read"
  ON public.notifications FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid()::text OR user_id = 'global')
  WITH CHECK (user_id = auth.uid()::text OR user_id = 'global');

CREATE POLICY "Admins can manage notifications"
  ON public.notifications FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- S. USER DEVICE TOKENS ---
CREATE POLICY "Users can manage own device tokens"
  ON public.user_device_tokens FOR ALL
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- --- T. APP CONFIGS ---
CREATE POLICY "Authenticated users can read app configs"
  ON public.app_configs FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Admins can manage app configs"
  ON public.app_configs FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- U. MIGRATION UID MAP (Strictly internal / Admin only) ---
CREATE POLICY "Admins can view migration mapping"
  ON public.migration_uid_map FOR SELECT
  TO authenticated
  USING (public.is_admin());


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
      'Welcome Bonus Coins ðŸŽ',
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


-- ====================================================================
-- RANK EARN SAFE LOCAL/DEV SEED DATA
-- ====================================================================

-- 1. App Configurations
INSERT INTO public.app_configs (key, value) VALUES
  ('payment_settings', '{
    "upiId": "rankearn@upi",
    "merchantName": "Rankearn Official",
    "qrNote": "Enter exact amount and copy 12-digit UTR below",
    "coinsPerRupee": 20
  }'::jsonb),
  ('withdrawal_settings', '{
    "minCoins": 1000,
    "isUPIEnabled": true,
    "isBankEnabled": true,
    "feePercentage": 0,
    "withdrawalNote": "Withdrawals are processed within 24 hours directly to your UPI ID or Bank account.",
    "coinsPerRupee": 20
  }'::jsonb),
  ('lucky_wheel', '{
    "isActive": true,
    "spinCost": 0,
    "slices": [
      { "label": "5 Coins", "value": 5, "type": "coins", "color": "#10b981", "probability": 30 },
      { "label": "10 Coins", "value": 10, "type": "coins", "color": "#3b82f6", "probability": 25 },
      { "label": "25 Coins", "value": 25, "type": "coins", "color": "#6366f1", "probability": 15 },
      { "label": "Try Again", "value": 0, "type": "nothing", "color": "#64748b", "probability": 10 },
      { "label": "50 Coins", "value": 50, "type": "coins", "color": "#f59e0b", "probability": 10 },
      { "label": "5 Coins", "value": 5, "type": "coins", "color": "#10b981", "probability": 5 },
      { "label": "100 Coins", "value": 100, "type": "coins", "color": "#f43f5e", "probability": 3 },
      { "label": "10 Coins", "value": 10, "type": "coins", "color": "#3b82f6", "probability": 2 }
    ]
  }'::jsonb),
  ('referral_settings', '{
    "isActive": true,
    "referrerReward": 50,
    "refereeReward": 25,
    "commissionRate": 5,
    "minWithdrawal": 1000
  }'::jsonb),
  ('auth_settings', '{
    "requireEmailVerification": false
  }'::jsonb),
  ('feature_flags', '{
    "showSubscriptionTab": true
  }'::jsonb),
  ('battle_settings', '{
    "totalQuestions": 5,
    "timePerQuestion": 10,
    "botAccuracy": 0.65,
    "prizeMultiplier": 1.8,
    "entryStakes": [10, 50, 100]
  }'::jsonb)
ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value;

-- 2. Exam Categories
INSERT INTO public.exam_categories (id, name, normalized_name, icon_url, display_order) VALUES
  ('bpsc', 'BPSC', 'bpsc', 'https://api.dicebear.com/7.x/identicon/svg?seed=bpsc', 1),
  ('ssc', 'SSC CGL', 'ssc', 'https://api.dicebear.com/7.x/identicon/svg?seed=ssc', 2),
  ('upsc', 'UPSC CSE', 'upsc', 'https://api.dicebear.com/7.x/identicon/svg?seed=upsc', 3),
  ('railway', 'Railway RRB', 'railway', 'https://api.dicebear.com/7.x/identicon/svg?seed=rrb', 4),
  ('banking', 'Banking IBPS', 'banking', 'https://api.dicebear.com/7.x/identicon/svg?seed=banking', 5)
ON CONFLICT (id) DO NOTHING;

-- 3. Subjects / Categories
INSERT INTO public.categories (id, name, exam_category_id, topics) VALUES
  ('cat_history', 'Indian History', 'bpsc', ARRAY['Ancient History', 'Medieval India', 'Modern Freedom Struggle']),
  ('cat_polity', 'Indian Polity', 'upsc', ARRAY['Preamble', 'Fundamental Rights', 'Directive Principles']),
  ('cat_quant', 'Quantitative Aptitude', 'ssc', ARRAY['Percentages', 'Profit & Loss', 'Time & Work', 'Algebra']),
  ('cat_science', 'General Science', 'railway', ARRAY['Physics', 'Chemistry', 'Biology'])
ON CONFLICT (id) DO NOTHING;

-- 4. Sample Test Series
INSERT INTO public.tests (
  id, title, exam_category_id, category_id, test_mode, duration_minutes,
  total_questions, negative_marking, is_premium, status, is_tournament, entry_fee_coins
) VALUES
  ('test_bpsc_mock_1', '70th BPSC Prelims Full Mock Test 1', 'bpsc', 'cat_history', 'mock', 120, 5, 0.25, false, 'published', false, 0),
  ('test_ssc_cgl_live', 'SSC CGL Grand Championship Tournament ðŸ†', 'ssc', 'cat_quant', 'tournament', 30, 5, 0.50, false, 'published', true, 20)
ON CONFLICT (id) DO NOTHING;

-- 5. Sample Questions for BPSC Mock 1
INSERT INTO public.questions (
  id, test_id, question_number, question_text_english, question_text_hindi, options, correct_answer, explanation_english, subject, topic
) VALUES
  ('q_bpsc_1', 'test_bpsc_mock_1', 1,
   'Who was the founder of the Maurya Empire?',
   'à¤®à¥Œà¤°à¥à¤¯ à¤¸à¤¾à¤®à¥à¤°à¤¾à¤œà¥à¤¯ à¤•à¥‡ à¤¸à¤‚à¤¸à¥à¤¥à¤¾à¤ªà¤• à¤•à¥Œà¤¨ à¤¥à¥‡?',
   '[{"textEnglish": "Chandragupta Maurya", "textHindi": "à¤šà¤¨à¥à¤¦à¥à¤°à¤—à¥à¤ªà¥à¤¤ à¤®à¥Œà¤°à¥à¤¯"}, {"textEnglish": "Ashoka", "textHindi": "à¤…à¤¶à¥‹à¤•"}, {"textEnglish": "Bindusara", "textHindi": "à¤¬à¤¿à¤¨à¥à¤¦à¥à¤¸à¤¾à¤°"}, {"textEnglish": "Bimbisara", "textHindi": "à¤¬à¤¿à¤®à¥à¤¬à¤¿à¤¸à¤¾à¤°"}]'::jsonb,
   0, 'Chandragupta Maurya founded the Maurya Empire in 322 BCE with the guidance of Chanakya.', 'History', 'Ancient History'),
  ('q_bpsc_2', 'test_bpsc_mock_1', 2,
   'Which article of the Indian Constitution deals with the Right to Equality?',
   'à¤­à¤¾à¤°à¤¤à¥€à¤¯ à¤¸à¤‚à¤µà¤¿à¤§à¤¾à¤¨ à¤•à¤¾ à¤•à¥Œà¤¨ à¤¸à¤¾ à¤…à¤¨à¥à¤šà¥à¤›à¥‡à¤¦ à¤¸à¤®à¤¾à¤¨à¤¤à¤¾ à¤•à¥‡ à¤…à¤§à¤¿à¤•à¤¾à¤° à¤¸à¥‡ à¤¸à¤‚à¤¬à¤‚à¤§à¤¿à¤¤ à¤¹à¥ˆ?',
   '[{"textEnglish": "Article 12", "textHindi": "à¤…à¤¨à¥à¤šà¥à¤›à¥‡à¤¦ 12"}, {"textEnglish": "Article 14", "textHindi": "à¤…à¤¨à¥à¤šà¥à¤›à¥‡à¤¦ 14"}, {"textEnglish": "Article 19", "textHindi": "à¤…à¤¨à¥à¤šà¥à¤›à¥‡à¤¦ 19"}, {"textEnglish": "Article 21", "textHindi": "à¤…à¤¨à¥à¤šà¥à¤›à¥‡à¤¦ 21"}]'::jsonb,
   1, 'Article 14 guarantees equality before the law and equal protection of the laws.', 'Polity', 'Fundamental Rights')
ON CONFLICT (id) DO NOTHING;

-- 6. Sample Promotional Banner
INSERT INTO public.app_banners (id, image_url, title, link, is_active, priority) VALUES
  ('banner_welcome', 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=1200&auto=format&fit=crop', 'Rankearn Championship League', '/earn', true, 1)
ON CONFLICT (id) DO NOTHING;

