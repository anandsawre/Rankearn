-- ====================================================================
-- ALLOW 'battle_entry' AND 'contest_entry' IN wallet_transactions
-- Fixes HTTP 400 Bad Request when deducting 1v1 battle or contest entry fees
-- ====================================================================

ALTER TABLE public.wallet_transactions
  DROP CONSTRAINT IF EXISTS wallet_transactions_category_check;

ALTER TABLE public.wallet_transactions
  ADD CONSTRAINT wallet_transactions_category_check
  CHECK (
    (category)::text = ANY (
      (ARRAY[
        'top_up'::character varying,
        'tournament_entry'::character varying,
        'tournament_prize'::character varying,
        'contest_entry'::character varying,
        'battle_entry'::character varying,
        'battle_win'::character varying,
        'battle_refund'::character varying,
        'reward'::character varying,
        'admin_credit'::character varying,
        'referral'::character varying,
        'spin_wheel'::character varying,
        'unlock_test'::character varying,
        'withdrawal'::character varying
      ])::text[]
    )
  );
