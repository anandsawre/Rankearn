-- ====================================================================
-- FIX SUPPORT TICKETS & MESSAGES RLS POLICIES AND ENABLE REALTIME
-- Fixes:
-- 1. Dynamically drops ALL existing policies first (prevents ERROR: 0A000)
-- 2. Foreign key / UUID restrictions for multi-platform client compatibility
-- 3. Enables Supabase Realtime WebSocket broadcast for live support streaming
-- ====================================================================

-- STEP 1: DYNAMICALLY DROP ALL EXISTING POLICIES ON BOTH TABLES FIRST
DO $$
DECLARE
    pol record;
BEGIN
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'support_tickets' AND schemaname = 'public' LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.support_tickets', pol.policyname);
    END LOOP;

    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'support_messages' AND schemaname = 'public' LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.support_messages', pol.policyname);
    END LOOP;
END $$;

-- STEP 2: REMOVE FOREIGN KEYS & ALTER COLUMN TYPES SAFELY
ALTER TABLE public.support_tickets DROP CONSTRAINT IF EXISTS support_tickets_user_id_fkey;
ALTER TABLE public.support_tickets ALTER COLUMN user_id TYPE VARCHAR(64) USING user_id::text;

ALTER TABLE public.support_messages DROP CONSTRAINT IF EXISTS support_messages_sender_id_fkey;
ALTER TABLE public.support_messages ALTER COLUMN sender_id TYPE VARCHAR(64) USING sender_id::text;

-- Expand status check constraint for Admin workflow
ALTER TABLE public.support_tickets DROP CONSTRAINT IF EXISTS support_tickets_status_check;
ALTER TABLE public.support_tickets ADD CONSTRAINT support_tickets_status_check 
  CHECK (status IN ('open', 'in_progress', 'resolved', 'on_hold', 'closed'));

-- Ensure additional admin columns exist
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='support_tickets' AND column_name='category') THEN
    ALTER TABLE public.support_tickets ADD COLUMN category VARCHAR(50) DEFAULT 'General';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='support_tickets' AND column_name='priority') THEN
    ALTER TABLE public.support_tickets ADD COLUMN priority VARCHAR(20) DEFAULT 'Medium';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='support_tickets' AND column_name='subject') THEN
    ALTER TABLE public.support_tickets ADD COLUMN subject TEXT;
  END IF;
EXCEPTION WHEN OTHERS THEN
  NULL;
END $$;

-- STEP 3: ENABLE RLS & CREATE NEW OPEN POLICIES
ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can manage support tickets"
  ON public.support_tickets FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Anyone can manage support messages"
  ON public.support_messages FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

-- STEP 4: ENABLE SUPABASE REALTIME BROADCAST
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
      AND schemaname = 'public' 
      AND tablename = 'support_tickets'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.support_tickets;
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
      AND schemaname = 'public' 
      AND tablename = 'support_messages'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.support_messages;
  END IF;
END $$;
