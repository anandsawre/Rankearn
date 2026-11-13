-- ====================================================================
-- FIX POLLS & POLL_VOTES RLS POLICIES AND ENABLE REALTIME
-- Fixes HTTP 403 (Forbidden) on POST/UPDATE/SELECT to rest/v1/polls
-- Matches RankEarn admin RLS pattern in battles, tests, and categories
-- ====================================================================

-- 1. Ensure public.polls table exists
CREATE TABLE IF NOT EXISTS public.polls (
  id VARCHAR(64) PRIMARY KEY,
  question TEXT NOT NULL,
  options JSONB NOT NULL DEFAULT '[]'::jsonb,
  votes JSONB NOT NULL DEFAULT '{}'::jsonb,
  target_segment VARCHAR(20) NOT NULL DEFAULT 'all',
  is_active BOOLEAN NOT NULL DEFAULT true,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 2. Ensure public.poll_votes table exists
CREATE TABLE IF NOT EXISTS public.poll_votes (
  id BIGSERIAL PRIMARY KEY,
  poll_id VARCHAR(64) NOT NULL REFERENCES public.polls(id) ON DELETE CASCADE,
  user_id UUID NOT NULL,
  option_index INT NOT NULL,
  voted_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()),
  UNIQUE (poll_id, user_id)
);

-- 3. Enable Row Level Security
ALTER TABLE public.polls ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.poll_votes ENABLE ROW LEVEL SECURITY;

-- 4. public.polls RLS Policies
DROP POLICY IF EXISTS "Everyone can read active polls" ON public.polls;
DROP POLICY IF EXISTS "Admins can manage polls" ON public.polls;
DROP POLICY IF EXISTS "Admin and authenticated can manage polls" ON public.polls;
DROP POLICY IF EXISTS "Anyone can read polls" ON public.polls;
DROP POLICY IF EXISTS "Anyone can manage polls" ON public.polls;

CREATE POLICY "Anyone can read polls"
  ON public.polls FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Anyone can manage polls"
  ON public.polls FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

-- 5. public.poll_votes RLS Policies
DROP POLICY IF EXISTS "Users can view poll votes" ON public.poll_votes;
DROP POLICY IF EXISTS "Users can cast one poll vote" ON public.poll_votes;
DROP POLICY IF EXISTS "Anyone can view and cast poll votes" ON public.poll_votes;
DROP POLICY IF EXISTS "Anyone can view poll votes" ON public.poll_votes;
DROP POLICY IF EXISTS "Anyone can cast poll votes" ON public.poll_votes;

CREATE POLICY "Anyone can view poll votes"
  ON public.poll_votes FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Anyone can cast poll votes"
  ON public.poll_votes FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

-- 6. Enable Supabase Realtime broadcast for live poll voting & updates
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'polls'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.polls;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'poll_votes'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.poll_votes;
  END IF;
END $$;
