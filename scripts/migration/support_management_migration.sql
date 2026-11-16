-- ====================================================================
-- FIX SUPPORT TICKETS & MESSAGES RLS POLICIES AND ENABLE REALTIME
-- Fixes:
-- 1. Drops old dependent policies first (fixes ERROR: 0A000)
-- 2. Foreign key / UUID restrictions for multi-platform client compatibility
-- 3. Enables Supabase Realtime WebSocket broadcast for live support streaming
-- ====================================================================

-- STEP 1: DROP ALL OLD DEPENDENT POLICIES FIRST
DROP POLICY IF EXISTS "Users view own support ticket" ON public.support_tickets;
DROP POLICY IF EXISTS "Users view own tickets" ON public.support_tickets;
DROP POLICY IF EXISTS "Users can create own support ticket" ON public.support_tickets;
DROP POLICY IF EXISTS "Users can create own tickets" ON public.support_tickets;
DROP POLICY IF EXISTS "Users and admins can update ticket status" ON public.support_tickets;
DROP POLICY IF EXISTS "Users and admins can update tickets" ON public.support_tickets;
DROP POLICY IF EXISTS "Anyone can read support tickets" ON public.support_tickets;
DROP POLICY IF EXISTS "Anyone can manage support tickets" ON public.support_tickets;

DROP POLICY IF EXISTS "Users and admins can read messages in their tickets" ON public.support_messages;
DROP POLICY IF EXISTS "Users and admins can read messages" ON public.support_messages;
DROP POLICY IF EXISTS "Users and admins can send messages in their tickets" ON public.support_messages;
DROP POLICY IF EXISTS "Users and admins can send messages" ON public.support_messages;
DROP POLICY IF EXISTS "Anyone can read support messages" ON public.support_messages;
DROP POLICY IF EXISTS "Anyone can manage support messages" ON public.support_messages;

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
