-- ==============================================================================
-- Rankearn Admin Panel — Tournaments Management Migration
-- Database Schema, Functions, RLS Policies, and Seed Data for Tournaments
-- ==============================================================================

-- 1. Ensure tournament columns exist on tests table
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tests' AND column_name = 'is_tournament') THEN
    ALTER TABLE public.tests ADD COLUMN is_tournament BOOLEAN NOT NULL DEFAULT false;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tests' AND column_name = 'prize_pool') THEN
    ALTER TABLE public.tests ADD COLUMN prize_pool INT NOT NULL DEFAULT 10000;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tests' AND column_name = 'entry_fee_coins') THEN
    ALTER TABLE public.tests ADD COLUMN entry_fee_coins INT NOT NULL DEFAULT 0;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'tests' AND column_name = 'max_participants') THEN
    ALTER TABLE public.tests ADD COLUMN max_participants INT NOT NULL DEFAULT 10000;
  END IF;
END $$;

-- 2. Indexes for fast query performance
CREATE INDEX IF NOT EXISTS idx_tests_tournament_status 
  ON public.tests(is_tournament, status, scheduled_start_time, scheduled_end_time);

-- 3. Tournament Participants Table
CREATE TABLE IF NOT EXISTS public.tournament_participants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  test_id VARCHAR(100) NOT NULL REFERENCES public.tests(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fee_paid INT NOT NULL DEFAULT 0,
  score NUMERIC(6, 2) DEFAULT 0.00,
  rank INT,
  status VARCHAR(30) NOT NULL DEFAULT 'registered' CHECK (status IN ('registered', 'confirmed', 'participated', 'disqualified', 'refunded')),
  joined_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
  UNIQUE(test_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_tournament_participants_test_user 
  ON public.tournament_participants(test_id, user_id);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.tournament_participants ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'tournament_participants' AND policyname = 'Public view tournament participants'
  ) THEN
    CREATE POLICY "Public view tournament participants"
      ON public.tournament_participants FOR SELECT
      USING (true);
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE tablename = 'tournament_participants' AND policyname = 'Admins manage tournament participants'
  ) THEN
    CREATE POLICY "Admins manage tournament participants"
      ON public.tournament_participants FOR ALL
      USING (
        EXISTS (
          SELECT 1 FROM public.profiles
          WHERE profiles.id = auth.uid() AND profiles.role = 'admin'
        )
      );
  END IF;
END $$;

-- 5. Seed Tournaments Data matching the Pixel-Accurate UI Reference
INSERT INTO public.tests (
  id, title, description, category, test_mode, is_tournament, 
  entry_fee_coins, prize_pool, max_participants, total_participants, 
  status, scheduled_start_time, scheduled_end_time
) VALUES
(
  'tour_001',
  'RRB Technician Grand Quiz',
  'All India Live Quiz Tournament',
  'Railway',
  'tournament',
  true,
  0,
  50000,
  10000,
  3240,
  'upcoming',
  '2026-10-25 19:00:00+05:30',
  '2026-10-25 21:00:00+05:30'
),
(
  'tour_002',
  'General Science Champion',
  'Science Special Tournament',
  'General Science',
  'tournament',
  true,
  10,
  25000,
  5000,
  2120,
  'ongoing',
  '2026-10-20 18:00:00+05:30',
  '2026-10-20 20:00:00+05:30'
),
(
  'tour_003',
  'Maths Master Tournament',
  'Speed & Accuracy Challenge',
  'Mathematics',
  'tournament',
  true,
  0,
  30000,
  8000,
  4850,
  'completed',
  '2026-10-18 17:00:00+05:30',
  '2026-10-18 19:00:00+05:30'
),
(
  'tour_004',
  'Current Affairs Cup',
  'Daily Current Affairs Quiz',
  'Current Affairs',
  'tournament',
  true,
  5,
  15000,
  5000,
  1940,
  'completed',
  '2026-10-15 20:00:00+05:30',
  '2026-10-15 21:30:00+05:30'
),
(
  'tour_005',
  'Bihar State Mega Quiz',
  'Bihar Special Tournament',
  'State Level',
  'tournament',
  true,
  20,
  40000,
  5000,
  2680,
  'completed',
  '2026-10-12 19:00:00+05:30',
  '2026-10-12 21:00:00+05:30'
),
(
  'tour_006',
  'Reasoning Challenge',
  'Logic & Reasoning Quiz',
  'Reasoning',
  'tournament',
  true,
  10,
  10000,
  3000,
  980,
  'archived',
  '2026-10-10 18:30:00+05:30',
  '2026-10-10 20:00:00+05:30'
),
(
  'tour_007',
  'Biology Battle',
  'Cell & Human Biology Quiz',
  'Biology',
  'tournament',
  true,
  0,
  5000,
  2000,
  640,
  'archived',
  '2026-10-05 19:00:00+05:30',
  '2026-10-05 20:30:00+05:30'
)
ON CONFLICT (id) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  category = EXCLUDED.category,
  entry_fee_coins = EXCLUDED.entry_fee_coins,
  prize_pool = EXCLUDED.prize_pool,
  total_participants = EXCLUDED.total_participants,
  status = EXCLUDED.status,
  scheduled_start_time = EXCLUDED.scheduled_start_time,
  scheduled_end_time = EXCLUDED.scheduled_end_time;
