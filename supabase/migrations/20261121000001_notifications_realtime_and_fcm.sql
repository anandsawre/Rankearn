-- ====================================================================
-- 20261121000001_notifications_realtime_and_fcm.sql
-- Enables: Realtime notifications feed, FCM push delivery, & tracking
-- ====================================================================

-- 1. Ensure public.notifications table exists
CREATE TABLE IF NOT EXISTS public.notifications (
  id VARCHAR(64) PRIMARY KEY,
  user_id VARCHAR(64) NOT NULL DEFAULT 'global',
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(30) NOT NULL DEFAULT 'alert',
  action_url TEXT,
  image_url TEXT,
  is_read BOOLEAN NOT NULL DEFAULT false,
  read_by UUID[] DEFAULT '{}',
  target_segment VARCHAR(30) DEFAULT 'all',
  clicks BIGINT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_created 
  ON public.notifications(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_segment 
  ON public.notifications(target_segment, created_at DESC);

-- 2. Ensure public.user_device_tokens table exists
CREATE TABLE IF NOT EXISTS public.user_device_tokens (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  platform VARCHAR(20) NOT NULL DEFAULT 'android',
  last_seen_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_device_tokens_user 
  ON public.user_device_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_device_tokens_token 
  ON public.user_device_tokens(token);

-- 3. Enable Row Level Security (RLS)
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_device_tokens ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies
DROP POLICY IF EXISTS "Users can view personal and global notifications" ON public.notifications;
DROP POLICY IF EXISTS "Public can view notifications" ON public.notifications;
CREATE POLICY "Users can view personal and global notifications"
  ON public.notifications FOR SELECT
  TO authenticated, anon
  USING (
    user_id = 'global' 
    OR (auth.uid() IS NOT NULL AND user_id = auth.uid()::text)
    OR true
  );

DROP POLICY IF EXISTS "Admins can manage notifications" ON public.notifications;
DROP POLICY IF EXISTS "Allow notifications management" ON public.notifications;
CREATE POLICY "Admins can manage notifications"
  ON public.notifications FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

DROP POLICY IF EXISTS "Users can manage own device tokens" ON public.user_device_tokens;
DROP POLICY IF EXISTS "Allow user device tokens management" ON public.user_device_tokens;
CREATE POLICY "Users can manage own device tokens"
  ON public.user_device_tokens FOR ALL
  TO authenticated, anon
  USING (
    auth.uid() IS NULL 
    OR user_id = auth.uid()
  )
  WITH CHECK (
    auth.uid() IS NULL 
    OR user_id = auth.uid()
  );

-- 5. Add to Supabase Realtime Publication
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'notifications'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
  END IF;
END $$;

-- 6. RPC Helpers
CREATE OR REPLACE FUNCTION public.increment_notification_clicks(p_notification_id text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.notifications
  SET clicks = clicks + 1
  WHERE id = p_notification_id;
END;
$$;

CREATE OR REPLACE FUNCTION public.mark_notification_read(p_notification_id text, p_user_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.notifications
  SET 
    is_read = true,
    read_by = CASE 
      WHEN NOT (p_user_id = ANY(read_by)) THEN array_append(read_by, p_user_id)
      ELSE read_by 
    END
  WHERE id = p_notification_id;
END;
$$;
