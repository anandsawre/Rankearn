-- ====================================================================
-- RANK EARN SUPABASE SCHEMA MIGRATION 002: ROW LEVEL SECURITY POLICIES
-- ====================================================================

-- 1. Helper Security Functions (SECURITY DEFINER, STABLE, SEARCH_PATH fixed)

CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_id = auth.uid() AND role = 'admin'
  );
$$;

REVOKE EXECUTE ON FUNCTION public.is_admin() FROM public;
GRANT EXECUTE ON FUNCTION public.is_admin() TO authenticated;

CREATE OR REPLACE FUNCTION public.is_active_user()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND status = 'active'
  );
$$;

REVOKE EXECUTE ON FUNCTION public.is_active_user() FROM public;
GRANT EXECUTE ON FUNCTION public.is_active_user() TO authenticated;

-- ====================================================================
-- 2. ENABLE ROW LEVEL SECURITY ON ALL APPLICATION TABLES
-- ====================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_patterns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tournament_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.unlocked_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wallet_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.topup_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.withdrawal_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.polls ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.poll_votes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.battle_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.battles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.support_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feedbacks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_device_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.app_configs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.migration_uid_map ENABLE ROW LEVEL SECURITY;

-- ====================================================================
-- 3. TABLE-BY-TABLE POLICIES
-- ====================================================================

-- --- A. PROFILES ---
CREATE POLICY "Public profile display info"
  ON public.profiles FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Users can update own non-sensitive profile fields"
  ON public.profiles FOR UPDATE
  TO authenticated
  USING (id = auth.uid() AND public.is_active_user())
  WITH CHECK (
    id = auth.uid() AND
    -- Prevent tampering with balances, subscription, or role
    coins = (SELECT p.coins FROM public.profiles p WHERE p.id = auth.uid()) AND
    withdrawable_balance = (SELECT p.withdrawable_balance FROM public.profiles p WHERE p.id = auth.uid()) AND
    status = (SELECT p.status FROM public.profiles p WHERE p.id = auth.uid())
  );

CREATE POLICY "Admins full control on profiles"
  ON public.profiles FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- B. USER ROLES ---
CREATE POLICY "Users can view own roles"
  ON public.user_roles FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Admins can manage user roles"
  ON public.user_roles FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- C. EXAM CATEGORIES & CATEGORIES ---
CREATE POLICY "Everyone can read exam categories"
  ON public.exam_categories FOR SELECT
  TO authenticated, anon
  USING (is_published = true OR public.is_admin());

CREATE POLICY "Admins can manage exam categories"
  ON public.exam_categories FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

CREATE POLICY "Everyone can read categories"
  ON public.categories FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Admins can manage categories"
  ON public.categories FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- D. EXAM PATTERNS ---
CREATE POLICY "Authenticated users can view exam patterns"
  ON public.exam_patterns FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can manage exam patterns"
  ON public.exam_patterns FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- E. TESTS ---
CREATE POLICY "Everyone can read published tests"
  ON public.tests FOR SELECT
  TO authenticated, anon
  USING (status = 'published' OR public.is_admin());

CREATE POLICY "Admins can manage tests"
  ON public.tests FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- F. QUESTIONS ---
CREATE POLICY "Authenticated users can read test questions"
  ON public.questions FOR SELECT
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.tests t
    WHERE t.id = public.questions.test_id AND (t.status = 'published' OR public.is_admin())
  ));

CREATE POLICY "Admins can manage questions"
  ON public.questions FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- G. TOURNAMENT PARTICIPANTS ---
CREATE POLICY "Participants can view tournament list"
  ON public.tournament_participants FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins manage tournament participants"
  ON public.tournament_participants FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- H. UNLOCKED TESTS ---
CREATE POLICY "Users can view own unlocked tests"
  ON public.unlocked_tests FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR public.is_admin());

-- --- I. ATTEMPTS ---
CREATE POLICY "Users can read own attempts"
  ON public.attempts FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Admins can manage attempts"
  ON public.attempts FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- J. WALLET TRANSACTIONS (Append-only ledger, no client direct insert) ---
CREATE POLICY "Users can read own wallet transactions"
  ON public.wallet_transactions FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Admins can view all wallet transactions"
  ON public.wallet_transactions FOR SELECT
  TO authenticated
  USING (public.is_admin());

-- --- K. TOP-UP REQUESTS ---
CREATE POLICY "Users can view own top-up requests"
  ON public.topup_requests FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Users can create top-up requests"
  ON public.topup_requests FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = auth.uid() AND
    status = 'pending' AND
    amount > 0 AND
    length(utr) >= 10 AND
    public.is_active_user()
  );

CREATE POLICY "Admins can manage top-up requests"
  ON public.topup_requests FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- L. WITHDRAWAL REQUESTS ---
CREATE POLICY "Users can view own withdrawal requests"
  ON public.withdrawal_requests FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Users can create withdrawal requests"
  ON public.withdrawal_requests FOR INSERT
  TO authenticated
  WITH CHECK (
    user_id = auth.uid() AND
    status = 'pending' AND
    coins_deducted > 0 AND
    public.is_active_user()
  );

CREATE POLICY "Admins can manage withdrawal requests"
  ON public.withdrawal_requests FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- M. APP BANNERS & POSTS ---
CREATE POLICY "Everyone can read active banners"
  ON public.app_banners FOR SELECT
  TO authenticated, anon
  USING (is_active = true OR public.is_admin());

CREATE POLICY "Admins can manage banners"
  ON public.app_banners FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

CREATE POLICY "Everyone can read active posts"
  ON public.posts FOR SELECT
  TO authenticated, anon
  USING (is_active = true OR public.is_admin());

CREATE POLICY "Admins can manage posts"
  ON public.posts FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- N. POLLS & POLL VOTES ---
CREATE POLICY "Everyone can read active polls"
  ON public.polls FOR SELECT
  TO authenticated, anon
  USING (is_active = true OR public.is_admin());

CREATE POLICY "Admins can manage polls"
  ON public.polls FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

CREATE POLICY "Users can view poll votes"
  ON public.poll_votes FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Users can cast one poll vote"
  ON public.poll_votes FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid() AND public.is_active_user());

-- --- O. BATTLE QUESTIONS & BATTLES ---
CREATE POLICY "Authenticated users can read battle questions"
  ON public.battle_questions FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can manage battle questions"
  ON public.battle_questions FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

CREATE POLICY "Participants can view and update their battles"
  ON public.battles FOR ALL
  TO authenticated
  USING (creator_id = auth.uid() OR opponent_id = auth.uid() OR public.is_admin())
  WITH CHECK (creator_id = auth.uid() OR opponent_id = auth.uid() OR public.is_admin());

-- --- P. SUPPORT TICKETS & MESSAGES ---
CREATE POLICY "Users view own support ticket"
  ON public.support_tickets FOR SELECT
  TO authenticated
  USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Users can create own support ticket"
  ON public.support_tickets FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users and admins can update ticket status"
  ON public.support_tickets FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid() OR public.is_admin());

CREATE POLICY "Users and admins can read messages in their tickets"
  ON public.support_messages FOR SELECT
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.support_tickets t
    WHERE t.id = public.support_messages.ticket_id AND (t.user_id = auth.uid() OR public.is_admin())
  ));

CREATE POLICY "Users and admins can send messages in their tickets"
  ON public.support_messages FOR INSERT
  TO authenticated
  WITH CHECK (
    sender_id = auth.uid() AND
    EXISTS (
      SELECT 1 FROM public.support_tickets t
      WHERE t.id = ticket_id AND (t.user_id = auth.uid() OR public.is_admin())
    )
  );

-- --- Q. FEEDBACKS ---
CREATE POLICY "Admins can view feedbacks"
  ON public.feedbacks FOR SELECT
  TO authenticated
  USING (public.is_admin());

CREATE POLICY "Users can submit feedback"
  ON public.feedbacks FOR INSERT
  TO authenticated
  WITH CHECK (user_id = auth.uid());

-- --- R. NOTIFICATIONS ---
CREATE POLICY "Users can view personal and global notifications"
  ON public.notifications FOR SELECT
  TO authenticated
  USING (user_id = auth.uid()::text OR user_id = 'global' OR public.is_admin());

CREATE POLICY "Users can mark own notifications as read"
  ON public.notifications FOR UPDATE
  TO authenticated
  USING (user_id = auth.uid()::text OR user_id = 'global')
  WITH CHECK (user_id = auth.uid()::text OR user_id = 'global');

CREATE POLICY "Admins can manage notifications"
  ON public.notifications FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- S. USER DEVICE TOKENS ---
CREATE POLICY "Users can manage own device tokens"
  ON public.user_device_tokens FOR ALL
  TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- --- T. APP CONFIGS ---
CREATE POLICY "Authenticated users can read app configs"
  ON public.app_configs FOR SELECT
  TO authenticated, anon
  USING (true);

CREATE POLICY "Admins can manage app configs"
  ON public.app_configs FOR ALL
  TO authenticated
  USING (public.is_admin())
  WITH CHECK (public.is_admin());

-- --- U. MIGRATION UID MAP (Strictly internal / Admin only) ---
CREATE POLICY "Admins can view migration mapping"
  ON public.migration_uid_map FOR SELECT
  TO authenticated
  USING (public.is_admin());
