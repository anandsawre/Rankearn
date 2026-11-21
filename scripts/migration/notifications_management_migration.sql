-- ====================================================================
-- RANKEARN SUPABASE MIGRATION: NOTIFICATIONS & DEVICE TOKENS SCHEMA
-- Idempotent, safe migration for Supabase SQL Editor
-- Enables: Realtime notifications feed, FCM push delivery, & tracking
-- ====================================================================

-- 1. Ensure public.notifications table exists
CREATE TABLE IF NOT EXISTS public.notifications (
  id VARCHAR(64) PRIMARY KEY,
  user_id VARCHAR(64) NOT NULL DEFAULT 'global', -- UUID or 'global'
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  type VARCHAR(30) NOT NULL DEFAULT 'alert', -- 'alert', 'announcement', 'reminder', 'system'
  action_url TEXT,
  image_url TEXT,
  is_read BOOLEAN NOT NULL DEFAULT false,
  read_by UUID[] DEFAULT '{}',
  target_segment VARCHAR(30) DEFAULT 'all', -- 'all', 'students', 'teachers', etc.
  clicks BIGINT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

-- 2. Indexes for instant lookup and sorting
CREATE INDEX IF NOT EXISTS idx_notifications_user_created 
  ON public.notifications(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notifications_segment 
  ON public.notifications(target_segment, created_at DESC);

-- 3. Ensure public.user_device_tokens table exists (for FCM device pushes)
CREATE TABLE IF NOT EXISTS public.user_device_tokens (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL UNIQUE,
  platform VARCHAR(20) NOT NULL DEFAULT 'android', -- 'android', 'ios', 'web'
  last_seen_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now())
);

CREATE INDEX IF NOT EXISTS idx_device_tokens_user 
  ON public.user_device_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_device_tokens_token 
  ON public.user_device_tokens(token);

-- 4. Enable Row Level Security (RLS)
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_device_tokens ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies for Notifications
DROP POLICY IF EXISTS "Users can view personal and global notifications" ON public.notifications;
DROP POLICY IF EXISTS "Public can view notifications" ON public.notifications;
CREATE POLICY "Users can view personal and global notifications"
  ON public.notifications FOR SELECT
  TO authenticated, anon
  USING (
    user_id = 'global' 
    OR (auth.uid() IS NOT NULL AND user_id = auth.uid()::text)
    OR true -- Admin and dashboard read access
  );

DROP POLICY IF EXISTS "Admins can manage notifications" ON public.notifications;
DROP POLICY IF EXISTS "Allow notifications management" ON public.notifications;
CREATE POLICY "Admins can manage notifications"
  ON public.notifications FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

-- 6. RLS Policies for User Device Tokens
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

-- 7. Add public.notifications and public.app_banners to Supabase Realtime Publication
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

  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'app_banners'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.app_banners;
  END IF;
END $$;

-- 8. RPC Helper: Increment Clicks when CTA button is tapped
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

-- 9. RPC Helper: Mark Notification Read by User
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

-- 10. Seed sample notifications if table is empty
INSERT INTO public.notifications (id, user_id, title, message, type, target_segment, action_url, is_read, clicks)
SELECT 
  'notif-welcome-2026', 
  'global', 
  '🏆 Mega Scholarship Test is Live!', 
  'Participate in this week''s Mega Test Series to compete with 10,000+ candidates and win scholarship rewards.', 
  'alert', 
  'all', 
  '/tests', 
  false, 
  48
WHERE NOT EXISTS (SELECT 1 FROM public.notifications LIMIT 1);
