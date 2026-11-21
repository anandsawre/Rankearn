-- ====================================================================
-- 20261121000002_scheduled_notifications_cron.sql
-- Enables: Cloud-side automated cron processor for scheduled notifications
-- Ensures notifications trigger even if admin/user app is closed!
-- ====================================================================

CREATE EXTENSION IF NOT EXISTS pg_cron;
CREATE EXTENSION IF NOT EXISTS pg_net;

CREATE OR REPLACE FUNCTION public.process_scheduled_notifications()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  r RECORD;
  processed_count INT := 0;
  now_utc TIMESTAMPTZ := timezone('utc'::text, now());
BEGIN
  FOR r IN
    SELECT id, channel, title, message, image_url, target_segment, action_url, action_label, type
    FROM public.notifications
    WHERE status = 'scheduled'
      AND scheduled_at IS NOT NULL
      AND scheduled_at <= now_utc
  LOOP
    -- 1. Mark as sent and bump created_at so Realtime delivers in-app alert to active devices
    UPDATE public.notifications
    SET status = 'sent',
        created_at = now_utc
    WHERE id = r.id;

    -- 2. If channel is 'push', trigger send-push edge function to wake up background/closed devices
    IF r.channel = 'push' THEN
      BEGIN
        PERFORM net.http_post(
          url := 'https://jybjomgwmabouahvvcuo.supabase.co/functions/v1/send-push',
          headers := jsonb_build_object(
            'Content-Type', 'application/json'
          ),
          body := jsonb_build_object(
            'title', r.title,
            'body', r.message,
            'imageUrl', r.image_url,
            'targetTopic', CASE WHEN r.target_segment = 'all' THEN 'all_users' ELSE r.target_segment END,
            'targetSegment', r.target_segment,
            'actionUrl', COALESCE(r.action_url, '/tests'),
            'actionLabel', COALESCE(r.action_label, 'Open'),
            'notificationId', r.id,
            'data', jsonb_build_object(
              'type', r.type,
              'channel', r.channel,
              'action_label', COALESCE(r.action_label, '')
            )
          )
        );
      EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'pg_net push dispatch notice for %: %', r.id, SQLERRM;
      END;
    END IF;

    processed_count := processed_count + 1;
  END LOOP;

  RETURN jsonb_build_object('processed', processed_count, 'timestamp', now_utc);
END;
$$;

-- Schedule pg_cron to run every minute in Supabase
DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
    BEGIN
      PERFORM cron.unschedule('process-scheduled-notifications');
    EXCEPTION WHEN OTHERS THEN END;

    PERFORM cron.schedule(
      'process-scheduled-notifications',
      '* * * * *',
      'SELECT public.process_scheduled_notifications();'
    );
  END IF;
EXCEPTION WHEN OTHERS THEN
  RAISE NOTICE 'pg_cron setup notice: %', SQLERRM;
END $$;
