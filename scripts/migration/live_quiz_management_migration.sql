-- ====================================================================
-- RANKEARN SUPABASE MIGRATION: LIVE QUIZ MANAGEMENT SCHEMA & SEED
-- Idempotent, safe migration for Supabase SQL Editor
-- ====================================================================

-- 1. Ensure tests table has required columns for live quizzes
CREATE TABLE IF NOT EXISTS public.tests (
  id VARCHAR(64) PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  category VARCHAR(64) DEFAULT 'General Science',
  category_id VARCHAR(64),
  test_mode VARCHAR(30) NOT NULL DEFAULT 'live_quiz',
  duration_minutes INT NOT NULL DEFAULT 45,
  total_questions INT NOT NULL DEFAULT 25,
  current_question_index INT NOT NULL DEFAULT 1,
  negative_marking NUMERIC(4, 2) NOT NULL DEFAULT 0.00,
  is_premium BOOLEAN NOT NULL DEFAULT false,
  prize_pool_coins INT DEFAULT 1500,
  status VARCHAR(20) NOT NULL DEFAULT 'scheduled',
  is_tournament BOOLEAN NOT NULL DEFAULT true,
  scheduled_start_time TIMESTAMPTZ,
  scheduled_end_time TIMESTAMPTZ,
  total_participants INT NOT NULL DEFAULT 0,
  is_result_declared BOOLEAN DEFAULT false,
  created_by VARCHAR(64) DEFAULT 'Admin',
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 2. Add any missing columns idempotently
DO $$ 
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tests' AND column_name='description') THEN
    ALTER TABLE public.tests ADD COLUMN description TEXT;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tests' AND column_name='category') THEN
    ALTER TABLE public.tests ADD COLUMN category VARCHAR(64) DEFAULT 'General Science';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='tests' AND column_name='current_question_index') THEN
    ALTER TABLE public.tests ADD COLUMN current_question_index INT NOT NULL DEFAULT 1;
  END IF;
END $$;

-- 3. Live Quiz Participants Tracking Table
CREATE TABLE IF NOT EXISTS public.live_quiz_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id VARCHAR(64) REFERENCES public.tests(id) ON DELETE CASCADE,
  user_id UUID,
  display_name VARCHAR(100) NOT NULL DEFAULT 'Student',
  joined_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  current_score INT NOT NULL DEFAULT 0,
  correct_answers INT NOT NULL DEFAULT 0,
  incorrect_answers INT NOT NULL DEFAULT 0,
  rank INT DEFAULT 0,
  is_connected BOOLEAN DEFAULT true,
  last_active_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 4. Fast Query Indexes
CREATE INDEX IF NOT EXISTS idx_tests_live_status ON public.tests(status);
CREATE INDEX IF NOT EXISTS idx_tests_live_category ON public.tests(category);
CREATE INDEX IF NOT EXISTS idx_tests_live_start_time ON public.tests(scheduled_start_time DESC);
CREATE INDEX IF NOT EXISTS idx_lq_participants_quiz_id ON public.live_quiz_participants(quiz_id);

-- 5. Enable Row Level Security (RLS)
ALTER TABLE public.tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.live_quiz_participants ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies
DROP POLICY IF EXISTS "Public can view live quizzes" ON public.tests;
CREATE POLICY "Public can view live quizzes"
  ON public.tests FOR SELECT
  USING (true);

DROP POLICY IF EXISTS "Admins can manage live quizzes" ON public.tests;
CREATE POLICY "Admins can manage live quizzes"
  ON public.tests FOR ALL
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Public can view live participants" ON public.live_quiz_participants;
CREATE POLICY "Public can view live participants"
  ON public.live_quiz_participants FOR SELECT
  USING (true);

-- 7. Seed Reference Live Quiz Dataset (Matching Primary Visual Specification Exactly)
INSERT INTO public.tests (
  id, title, description, category, test_mode, duration_minutes,
  total_questions, prize_pool_coins, total_participants, status,
  scheduled_start_time, created_by
) VALUES
  (
    'lq-001',
    'RRB Technician Mega Quiz',
    'Live quiz for RRB Technician',
    'Railway',
    'live_quiz',
    60,
    30,
    1500,
    1240,
    'completed',
    '2026-10-18 19:00:00+05:30',
    'Admin'
  ),
  (
    'lq-002',
    'General Science Live Quiz',
    'Science special live quiz',
    'General Science',
    'live_quiz',
    45,
    25,
    1000,
    980,
    'completed',
    '2026-10-17 20:00:00+05:30',
    'Admin'
  ),
  (
    'lq-003',
    'Maths Challenge Live',
    'Speed and accuracy test',
    'Mathematics',
    'live_quiz',
    30,
    20,
    2000,
    1850,
    'completed',
    '2026-10-16 19:30:00+05:30',
    'Admin'
  ),
  (
    'lq-004',
    'Current Affairs Live Quiz',
    'Daily current affairs',
    'Current Affairs',
    'live_quiz',
    45,
    25,
    2500,
    2340,
    'live',
    '2026-10-15 20:00:00+05:30',
    'Admin'
  ),
  (
    'lq-005',
    'Reasoning Power Quiz',
    'Logic and reasoning test',
    'Reasoning',
    'live_quiz',
    60,
    30,
    1200,
    1120,
    'scheduled',
    '2026-10-14 19:00:00+05:30',
    'Admin'
  ),
  (
    'lq-006',
    'Biology Live Quiz',
    'Cell & Human Biology',
    'Biology',
    'live_quiz',
    45,
    25,
    1000,
    860,
    'completed',
    '2026-10-13 18:30:00+05:30',
    'Admin'
  ),
  (
    'lq-007',
    'Mixed Topics Grand Quiz',
    'Full syllabus live quiz',
    'Mixed',
    'live_quiz',
    60,
    40,
    5000,
    3450,
    'ongoing',
    '2026-10-12 20:00:00+05:30',
    'Admin'
  )
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  category = EXCLUDED.category,
  duration_minutes = EXCLUDED.duration_minutes,
  total_questions = EXCLUDED.total_questions,
  prize_pool_coins = EXCLUDED.prize_pool_coins,
  total_participants = EXCLUDED.total_participants,
  status = EXCLUDED.status,
  scheduled_start_time = EXCLUDED.scheduled_start_time,
  updated_at = timezone('utc'::text, now());
