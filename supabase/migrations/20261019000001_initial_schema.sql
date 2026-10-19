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
