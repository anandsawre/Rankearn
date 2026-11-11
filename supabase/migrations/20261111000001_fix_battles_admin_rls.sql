-- ====================================================================
-- FIX BATTLES, APP_CONFIGS & NOTIFICATIONS RLS POLICIES FOR ADMIN SYNC
-- Matches the Admin App policy pattern in 20261027000001 & 20261030000001
-- ====================================================================

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.battles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- 0. public.user_roles (allow authenticated users to read their own admin role)
DROP POLICY IF EXISTS "Users can view own roles" ON public.user_roles;
CREATE POLICY "Users can view own roles"
  ON public.user_roles FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

-- 1. public.battles
DROP POLICY IF EXISTS "Participants can view and update their battles" ON public.battles;
DROP POLICY IF EXISTS "Admin and authenticated can manage battles" ON public.battles;

CREATE POLICY "Admin and authenticated can manage battles"
  ON public.battles FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

-- 2. public.app_configs (stores battle_settings & battle_admin_audit_logs)
DROP POLICY IF EXISTS "Admins can manage app configs" ON public.app_configs;

CREATE POLICY "Admins can manage app configs"
  ON public.app_configs FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

-- 3. public.notifications (stores global battle broadcasts)
DROP POLICY IF EXISTS "Admins can manage notifications" ON public.notifications;

CREATE POLICY "Admins can manage notifications"
  ON public.notifications FOR ALL
  TO authenticated, anon
  USING (true)
  WITH CHECK (true);

-- 4. Enable Realtime on public.battles if not already registered
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'battles'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.battles;
  END IF;
END $$;

