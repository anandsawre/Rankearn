# Rankearn Data Schema & Mapping Specification

**Intake Date:** 2026-10-19  
**Source Baseline:** `latest-main.zip` (`firestore.rules`, `packages/shared/src/types.ts`, `firebase-blueprint.json`)  
**Target Engine:** Supabase PostgreSQL with Relational Constraints, Versioned Migrations, and Row Level Security.

---

## 1. Relational Schema Architecture (Postgres)

```
                            +--------------------+
                            |     auth.users     | (Supabase Auth)
                            +---------+----------+
                                      | 1:1
                                      v
                            +--------------------+
                            |  public.profiles   |
                            +----+----------+----+
                                 |          |
        +------------------------+          +------------------------+
        | 1:N                                                        | 1:N
        v                                                            v
+--------------------+                                      +--------------------+
| wallet_transactions|                                      |   unlocked_tests   |
+--------------------+                                      +--------------------+
        ^                                                            |
        |                                                            v
+--------------------+      1:N     +--------------------+  N:1     +--------------------+
|   topup_requests   |<-------------|       tests        |--------->|  exam_categories   |
+--------------------+              +----+----------+----+          +--------------------+
                                         |          |
                                     1:N |          | 1:N
                                         v          v
                            +------------+---+  +---+----------------+
                            |   questions    |  |    attempts        |
                            +----------------+  +---+----------------+
                                                    |
                                                1:N v
                                                +--------------------+
                                                |   attempt_answers  |
                                                +--------------------+
```

---

## 2. Comprehensive Entity Mapping Matrix

### 1. Users & Identity Domain

#### Source: Firestore `users/{userId}`
- **Primary Key:** `userId` (Firebase Auth UID string)
- **Key Fields:** `name`, `email`, `phone`, `profilePhoto`, `examPreparingFor`, `state`, `coins`, `totalEarned`, `totalSpent`, `withdrawableBalance`, `badges`, `subscriptionStatus`, `subscriptionEndDate`, `createdAt`, `role`, `isLeaderboardEligible`, `fcmTokens`, `lastSpinDate`, `savedPaymentDetails`, `referredBy`, `referralCode`, `status`, `banReason`, `banUntil`, `violationCount`.

#### Target: PostgreSQL `public.profiles`
```sql
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
  referred_by UUID REFERENCES public.profiles(id),
  referral_code VARCHAR(16) UNIQUE,
  status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'banned')),
  ban_reason TEXT,
  ban_until TIMESTAMPTZ,
  violation_count INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);
```

---

### 2. Tests & Question Bank Domain

#### Source: Firestore `tests/{testId}` & Subcollection `questions/{qId}`
- **Test Fields:** `title`, `category`, `examCategory`, `testMode`, `duration`, `totalQuestions`, `negativeMarking`, `createdBy`, `isPremium`, `status`, `isTournament`, `entryFee`, `prizeDistribution`, `scheduledStartTime`, `scheduledEndTime`, `unlockPrice`, `syllabus`.
- **Question Fields:** `questionTextEnglish`, `questionTextHindi`, `options` array, `correctAnswer`, `explanation`, `explanationHindi`, `difficultyLevel`, `subject`, `topic`, `imageURL`.

#### Target: PostgreSQL `public.tests` & `public.questions`
```sql
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

CREATE TABLE public.categories (
  id VARCHAR(64) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  exam_category_id VARCHAR(64) REFERENCES public.exam_categories(id),
  topics TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

CREATE TABLE public.tests (
  id VARCHAR(64) PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  exam_category_id VARCHAR(64) REFERENCES public.exam_categories(id),
  category_id VARCHAR(64) REFERENCES public.categories(id),
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
  is_result_declared BOOLEAN DEFAULT false,
  syllabus TEXT,
  created_by UUID REFERENCES auth.users(id),
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

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
CREATE INDEX idx_questions_test_id ON public.questions(test_id);
```

---

### 3. Quiz Attempts & Scoring Domain

#### Source: Firestore `attempts/{attemptId}`
- **Attempt Fields:** `userId`, `testId`, `answers` map, `startTime`, `endTime`, `score`, `accuracy`, `rank`, `timeTaken`, `coinsEarned`, `isTournament`.

#### Target: PostgreSQL `public.attempts`
```sql
CREATE TABLE public.attempts (
  id VARCHAR(64) PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  test_id VARCHAR(64) NOT NULL REFERENCES public.tests(id) ON DELETE CASCADE,
  answers JSONB NOT NULL, -- Map: { "qId": selectedOptionIndex }
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  time_taken_seconds INT NOT NULL CHECK (time_taken_seconds >= 0),
  score NUMERIC(6, 2) NOT NULL,
  accuracy NUMERIC(5, 2) NOT NULL,
  rank INT,
  is_tournament BOOLEAN DEFAULT false,
  coins_earned INT DEFAULT 0,
  is_coins_awarded BOOLEAN DEFAULT false,
  status VARCHAR(20) DEFAULT 'completed',
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);
CREATE INDEX idx_attempts_user_test ON public.attempts(user_id, test_id);
CREATE INDEX idx_attempts_test_score ON public.attempts(test_id, score DESC, time_taken_seconds ASC);
```

---

### 4. Financial Ledger & Wallet Domain

#### Source: Firestore `transactions/{txId}`, `topup_requests/{reqId}`, `withdrawal_requests/{reqId}`
- **Ledger Invariants:**
  1. Transaction records are strictly append-only.
  2. Currency precision: Rupee amounts stored with explicit `NUMERIC(12, 2)` precision.
  3. Coin movements stored as `BIGINT`.
  4. Top-up UTR enforced as unique across the platform to eliminate transaction replay.

#### Target: PostgreSQL Ledger Schema
```sql
CREATE TABLE public.wallet_transactions (
  id VARCHAR(64) PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  amount BIGINT NOT NULL CHECK (amount <> 0), -- Positive for earn, negative for spend
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
CREATE INDEX idx_wallet_tx_user_time ON public.wallet_transactions(user_id, created_at DESC);

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
```

---

### 5. Content, Gamification & Operational Domain

#### Target: Auxiliary PostgreSQL Tables
- `public.app_banners`: Banner images, title, target route, priority, scheduled times, click counter.
- `public.posts`: Official updates, current affairs, rich HTML content, author name.
- `public.polls` & `public.poll_votes`: Questions, options, vote distribution, voter user foreign keys.
- `public.battle_questions`: Fast-paced 1v1 battle questions in English/Hindi with difficulty tags.
- `public.battles`: Active/resolved 1v1 battle matches, stakes, scores, winner UUID.
- `public.support_tickets` & `public.support_messages`: Realtime customer support conversations.
- `public.feedbacks`: User satisfaction ratings (1-5 stars) and qualitative feedback comments.
- `public.app_configs`: Key-value configuration documents (`payment_settings`, `withdrawal_settings`, `lucky_wheel`, `referral_settings`, `auth_settings`, `feature_flags`).
- `public.user_device_tokens`: FCM registration tokens with platform tag and last active timestamp.
- `public.user_roles`: Server-enforced role authorization matrix (`user_id`, `role`, `granted_at`, `granted_by`).
