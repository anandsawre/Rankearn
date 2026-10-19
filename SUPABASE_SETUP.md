# Rankearn Supabase Database Setup Guide

Yeh file aapko Rankearn ke complete Supabase database ko 1-click me deploy karne ka step-by-step procedure batati hai.

---

## 📁 Master SQL Files Ki Location

Aapke project me complete, self-contained production database schema save hai:

1. **Project Root Par**: [**`rankearn_master_schema.sql`**](file:///d:/Rankearn/rankearn_master_schema.sql) *(Directly visible in explorer)*
2. **Supabase Folder Me**: [**`supabase/rankearn_master_schema.sql`**](file:///d:/Rankearn/supabase/rankearn_master_schema.sql)
3. **Migration History Me**: [**`supabase/migrations/`**](file:///d:/Rankearn/supabase/migrations/)

---

## 🚀 Supabase Dashboard Me 1-Click Run Kaise Karein

1. Apne browser me **[Supabase Dashboard](https://supabase.com/dashboard)** open karein.
2. Apna **Rankearn** project select karein.
3. Left-hand side menu me **SQL Editor** (`>_` icon) par click karein.
4. **`+ New Query`** par click karein.
5. [**`rankearn_master_schema.sql`**](file:///d:/Rankearn/rankearn_master_schema.sql) file open karein, sara code (`Ctrl + A`, `Ctrl + C`) copy karke Supabase SQL Editor me paste karein.
6. Bottom-right me green **RUN** button par click karein.

---

## 📦 Is Master File Me Kya-Kya Shamil Hai?

Yeh single file poore backend ko zero se 100% build kar deti hai:

### 1. All 24 Application Tables
- `profiles` (User balances, coins, subscription, referral code)
- `user_roles` (Server-side RBAC: 'user', 'support', 'admin')
- `exam_categories` (70th BPSC, SSC CGL, Railway NTPC, UPSC CSE)
- `categories` (Syllabus subjects & topics)
- `exam_patterns` (Blueprints for AI question generator)
- `tests` (Mock tests, full series & live tournament contests)
- `questions` (Bilingual English + Hindi questions, options & solutions)
- `tournament_participants` (Contest registrations & fee logs)
- `unlocked_tests` (Permanent coin test unlocks)
- `attempts` (Quiz results, timing, accuracy, ranks)
- `wallet_transactions` (Strict append-only financial ledger)
- `topup_requests` (UPI deposit approval queue with UTR verification)
- `withdrawal_requests` (Coin redemptions to UPI or Bank)
- `app_banners` (Promotional carousels & student spotlights)
- `posts` (Official updates & current affairs)
- `polls` & `poll_votes` (Daily community polls)
- `battle_questions` & `battles` (1v1 live duel arena)
- `support_tickets` & `support_messages` (Live customer support chat)
- `feedbacks` (Student reviews & star ratings)
- `notifications` & `user_device_tokens` (FCM push alert engine)
- `app_configs` (Payment VPA, lucky wheel drop rates, referral rules)
- `migration_uid_map` (Legacy Firebase UID mapping)

### 2. Row Level Security (RLS) & Security Functions
- `is_admin()` and `is_active_user()` functions with `SECURITY DEFINER`.
- RLS enabled on all 24 tables.
- Granular permissions for SELECT, INSERT, UPDATE, and DELETE.

### 3. Atomic Stored Procedures (RPCs)
- `handle_new_user`: Auth trigger for automatic profile & welcome bonus generation.
- `join_tournament`: Atomic row-lock, fee deduction & contest entry.
- `spin_lucky_wheel`: Server-side drop probability execution & coin crediting.
- `process_topup_request`: Admin deposit approval with atomic balance top-up.
- `process_withdrawal_request`: Payout marking or coin refund on rejection.
- `admin_adjust_balance`: Manual coin credit/debit tool.

### 4. Seed Data
- Default Payment UPI configuration (`rankearn@upi`, 20 coins = ₹1).
- Lucky wheel 8 reward slices configuration.
- Referral rewards configuration.
- Initial exam categories & sample mock test series with bilingual questions.
