-- ====================================================================
-- RANKEARN SUPABASE MIGRATION: TEST SERIES MANAGEMENT SCHEMA & SEED
-- Idempotent, safe migration for Supabase SQL Editor
-- ====================================================================

-- 1. Ensure tests table exists
CREATE TABLE IF NOT EXISTS public.tests (
  id VARCHAR(64) PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  exam_category_id VARCHAR(64),
  category_id VARCHAR(64),
  test_mode VARCHAR(30) NOT NULL DEFAULT 'mock',
  duration_minutes INT NOT NULL DEFAULT 60,
  total_questions INT NOT NULL DEFAULT 0,
  negative_marking NUMERIC(4, 2) NOT NULL DEFAULT 0.00,
  is_premium BOOLEAN NOT NULL DEFAULT false,
  is_pro_only BOOLEAN NOT NULL DEFAULT false,
  unlock_price_coins INT DEFAULT 0,
  status VARCHAR(20) NOT NULL DEFAULT 'published',
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
  created_by UUID,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 2. Indexes for fast query and filtering
CREATE INDEX IF NOT EXISTS idx_tests_status ON public.tests(status);
CREATE INDEX IF NOT EXISTS idx_tests_category ON public.tests(category_id);
CREATE INDEX IF NOT EXISTS idx_tests_created_at ON public.tests(created_at DESC);

-- 3. Enable RLS
ALTER TABLE public.tests ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies
DROP POLICY IF EXISTS "Public can view published tests" ON public.tests;
CREATE POLICY "Public can view published tests"
  ON public.tests FOR SELECT
  USING (status = 'published' OR true);

DROP POLICY IF EXISTS "Admins can manage all tests" ON public.tests;
CREATE POLICY "Admins can manage all tests"
  ON public.tests FOR ALL
  USING (true)
  WITH CHECK (true);

-- 5. Seed Test Series Management Reference Dataset (Idempotent)
INSERT INTO public.tests (
  id, title, syllabus, category_id, test_mode, duration_minutes, total_questions,
  unlock_price_coins, total_participants, status, created_at
) VALUES
  (
    'ts-1',
    'RRB Technician Grade 3',
    'Complete test series with detailed solutions',
    'General Science',
    'mock',
    20,
    2000,
    199,
    3245,
    'published',
    '2026-10-10 10:00:00+00'
  ),
  (
    'ts-2',
    'Railway Maths Practice Series',
    'Topic wise and full length tests',
    'Mathematics',
    'sectional',
    25,
    2500,
    149,
    2891,
    'published',
    '2026-10-08 10:00:00+00'
  ),
  (
    'ts-3',
    'Reasoning Special Series',
    'Based on latest exam pattern',
    'Reasoning',
    'sectional',
    20,
    2000,
    149,
    1985,
    'published',
    '2026-10-05 10:00:00+00'
  ),
  (
    'ts-4',
    'Current Affairs Monthly Series',
    'Monthly current affairs tests',
    'Current Affairs',
    'mock',
    12,
    1200,
    99,
    1542,
    'published',
    '2026-10-01 10:00:00+00'
  ),
  (
    'ts-5',
    'Chemistry Practice Series',
    'Chapter wise tests with solutions',
    'Chemistry',
    'sectional',
    18,
    1800,
    129,
    1238,
    'draft',
    '2026-09-28 10:00:00+00'
  ),
  (
    'ts-6',
    'Biology Marathon Series',
    'Complete biology test series',
    'Biology',
    'sectional',
    15,
    1500,
    129,
    980,
    'published',
    '2026-09-25 10:00:00+00'
  ),
  (
    'ts-7',
    'Full Syllabus Mock Test Series',
    'Complete syllabus with previous year pattern',
    'Mixed',
    'mock',
    30,
    3000,
    249,
    1610,
    'published',
    '2026-09-20 10:00:00+00'
  )
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  syllabus = EXCLUDED.syllabus,
  category_id = EXCLUDED.category_id,
  duration_minutes = EXCLUDED.duration_minutes,
  total_questions = EXCLUDED.total_questions,
  unlock_price_coins = EXCLUDED.unlock_price_coins,
  total_participants = EXCLUDED.total_participants,
  status = EXCLUDED.status;
