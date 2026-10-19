# Rankearn Backend Dependency & Service Map

**Intake Date:** 2026-10-19  
**Source Baseline:** `latest-main.zip`  
**Purpose:** Comprehensive map of all current backend dependencies, third-party APIs, secrets, and target Supabase service allocations.

---

## 1. Backend Dependency Overview

```
                      +---------------------------------------+
                      |         Rankearn Client Layer         |
                      |   (Flutter User App & Admin App)      |
                      +-------------------+-------------------+
                                          |
        +---------------------------------+---------------------------------+
        |                                 |                                 |
        v                                 v                                 v
+----------------+              +--------------------+            +-------------------+
|  Supabase Auth |              |  Supabase Postgres |            |  Supabase Storage |
| (Target Truth) |              |   (Target Truth)   |            |   (Target Truth)  |
+----------------+              +--------------------+            +-------------------+
                                          ^                                 ^
                                          |                                 |
                               +----------+----------+                      |
                               |  Supabase Edge      |                      |
                               |  Functions / Worker |----------------------+
                               +----------+----------+
                                          |
                    +---------------------+---------------------+
                    |                                           |
                    v                                           v
       +-------------------------+                 +-------------------------+
       |   Gemini 1.5 Flash AI   |                 | Firebase Cloud Messaging|
       |     (Google GenAI)      |                 |  (FCM Push Notifications)|
       +-------------------------+                 +-------------------------+
```

---

## 2. Inventory of Current Backend Services

### A. Firebase Authentication (Current Primary Identity Provider)
- **Status in Source:** Active in `packages/shared/src/firebase.ts`, `apps/user/src/App.tsx`, and `apps/admin/src/App.tsx`.
- **Project ID:** `rankearn`
- **Supported Methods:**
  - Email & Password with `emailVerified` check
  - Google OAuth (`signInWithPopup` on web, `@codetrix-studio/capacitor-google-auth` on Android)
  - Password Reset (`sendPasswordResetEmail`)
- **Authorization Mechanics:**
  - Claims intended via `auth.setCustomUserClaims(uid, { admin: true })` (`scripts/setAdminClaim.ts`)
  - Flawed frontend bypass in `apps/admin/src/App.tsx` directly setting `{ role: 'admin' }` on Firestore document.
- **Migration Target:** Supabase Auth (`auth.users`), canonical UUID `auth.uid()`.

---

### B. Firebase Firestore (Current Primary Application Database)
- **Status in Source:** Active as primary document store across 27 collections.
- **Configuration:** Initialized with multi-tab persistence in `packages/shared/src/firebase.ts`.
- **Collections & Target Supabase Entities:**

| Firestore Collection / Subcollection | Usage & Business Scope | Target Supabase Postgres Entity |
|---|---|---|
| `users/{userId}` | User profile, coins, withdrawable balance, subscription status, referral codes. | `public.profiles` |
| `users/{userId}/unlockedTests/{testId}` | Set of premium test IDs unlocked permanently by the user. | `public.unlocked_tests` |
| `tests/{testId}` | Test series metadata, category, mode, duration, negative marking, tournament settings. | `public.tests` |
| `tests/{testId}/questions/{qId}` | Questions under a test with bilingual text, options, explanations, images. | `public.questions` |
| `tests/{testId}/participants/{uid}` | Registered tournament participants and entry fees. | `public.tournament_participants` |
| `attempts/{attemptId}` | User quiz attempt records, answers map, scores, accuracy, duration. | `public.attempts` |
| `leaderboard/{entryId}` | Snapshot entries for daily, weekly, monthly, and contest rankings. | `public.leaderboard_snapshots` (and live views) |
| `categories/{catId}` | Subjects (Mathematics, General Knowledge, History, etc.). | `public.categories` |
| `examCategories/{ecId}` | Root Exam classifications (BPSC, SSC, UPSC, Banking, etc.). | `public.exam_categories` |
| `examPatterns/{patId}` | Structural exam blueprints used by AI test generator. | `public.exam_patterns` |
| `transactions/{txId}` | Immutable financial ledger for coin movements (topup, earn, spend, withdrawal). | `public.wallet_transactions` |
| `topup_requests/{reqId}` | User manual UPI payment verification requests with UTR number. | `public.topup_requests` |
| `submitted_utrs/{utr}` | Unique lock documents preventing UTR replay attacks. | Unique constraint on `topup_requests.utr` |
| `withdrawal_requests/{reqId}` | User coin cash-out requests with UPI ID or bank account details. | `public.withdrawal_requests` |
| `notes/{noteId}` | Study notes and PDF attachments. | `public.study_notes` |
| `currentAffairs/{id}` | Daily current affairs posts. | Merged with `public.posts` (type='current_affairs') |
| `posts/{postId}` | Official announcements and news articles with rich text. | `public.posts` |
| `configs/{configId}` | Global platform configurations (`payment_settings`, `withdrawal_settings`, etc.). | `public.app_configs` |
| `app_banners/{bannerId}` | Promotional banners displayed on the dashboard. | `public.app_banners` |
| `support_tickets/{ticketId}` | User support tickets. | `public.support_tickets` |
| `support_tickets/{id}/messages/{mId}` | Support messages exchanged between user and admin. | `public.support_messages` |
| `feedbacks/{feedbackId}` | User star ratings and feedback submissions. | `public.feedbacks` |
| `notifications/{notifId}` | In-app alerts and broadcast logs. | `public.notifications` |
| `battle_questions/{qId}` | Question bank for 1v1 battle mode. | `public.battle_questions` |
| `battle_bots/{botId}` | Pre-configured simulation bots with difficulty and accuracy profiles. | `public.battle_bots` |
| `matchmaking/{mmId}` | Temporary matchmaking tickets for live battle discovery. | Ephemeral Realtime broadcast / Supabase table |
| `battles/{battleId}` | Active 1v1 battle matches, participant scores, winner resolution. | `public.battles` |
| `polls/{pollId}` | Community polls with vote counters and voter UID tracking. | `public.polls` + `public.poll_votes` |

---

### C. Supabase Storage & Database Integration (Already in Source)
- **Supabase Project:** `jybjomgwmabouahvvcuo` (`https://jybjomgwmabouahvvcuo.supabase.co`)
- **Client Initialization:** `packages/shared/src/supabase.ts`
- **Active Storage Buckets (managed via Worker):**
  1. `avatars`: User profile photos.
  2. `quiz-images`: Diagrams and images attached to quiz questions.
  3. `notification-images`: Images embedded in push notification broadcasts.
- **Active Database Usage:**
  - Worker endpoints `GET /profile` and `POST /profile` already perform direct upserts to `${supabaseUrl}/rest/v1/users`.

---

### D. Cloudflare Worker Edge Server
- **File:** `worker/cloudflare_worker.js` (1,198 lines)
- **Host / Deployment:** Cloudflare Workers
- **Endpoints Exposed:**
  1. `POST /upload-avatar`: Decodes base64 image, uploads to Supabase Storage bucket `avatars`.
  2. `POST /upload-quiz-image`: Uploads to Supabase Storage bucket `quiz-images`.
  3. `POST /upload-notification-image`: Uploads to Supabase Storage bucket `notification-images`.
  4. `GET /profile`: Queries Supabase Postgres `users` table via PostgREST.
  5. `POST /profile`: Upserts user profile in Supabase Postgres `users` table.
  6. `POST /subscribe-topic`: Subscribes FCM device token to topic via `iid.googleapis.com`.
  7. `POST /send-push`: Sends push notifications via FCM HTTP v1 API (`https://fcm.googleapis.com/v1/...`).
  8. `POST /submit-test`: Server-side scoring calculation, verifies questions, writes attempt document.
  9. `POST /submit-bot-battle`: Validates stakes, calculates user vs bot score, awards coins, logs transaction.
  10. `POST /` or `/gemini`: Proxies Gemini AI requests to `generativelanguage.googleapis.com`.

---

### E. Gemini AI Integration
- **SDK:** `@google/genai` (version 1.29.0)
- **Model:** `gemini-1.5-flash`
- **Primary Use Cases:**
  1. AI Exam Paper Generator (Admin Tab `ai-creator`): Generates comprehensive bilingual exam questions structured according to `ExamPattern`.
  2. AI Performance Analysis: Evaluates user attempt accuracy, highlights weak vs strong topics, and generates personalized recommendations.
- **Security Requirement:** `GEMINI_API_KEY` must never be bundled inside client code. All calls must route through trusted server-side Edge Functions.

---

### F. Push Notifications (Firebase Cloud Messaging)
- **Status:** FCM remains necessary for native Android push delivery via `@capacitor/push-notifications` and web service worker `public/firebase-messaging-sw.js`.
- **Approved Platform Service Exception:**
  - FCM is retained strictly as a notification delivery channel.
  - It does NOT serve as an application database or auth provider.
  - Device tokens are stored in Supabase table `public.user_device_tokens`.
  - Notification dispatch occurs via Supabase Edge Functions using Google Service Account credentials.

---

## 3. Privileged Secrets Inventory & Protection Rules

| Secret Name | Service | Current Exposure / Location | Target Vault / Security Action |
|---|---|---|---|
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase | Cloudflare Worker environment | Server-side only (Supabase Secrets / Cloudflare Secrets). NEVER bundle in Flutter. |
| `SUPABASE_ANON_KEY` | Supabase | `packages/shared/src/supabase.ts` | Publishable key in Flutter client with strict Row Level Security (RLS). |
| `SERVICE_KEY` | Firebase Admin | Cloudflare Worker environment | Server-side only for FCM HTTP v1 dispatch. |
| `GEMINI_API_KEY` | Google AI | Exposed in `apps/user/vite.config.ts` via `define` | **Critical Defect:** Move entirely behind Supabase Edge Function. |
| `debug.keystore` | Android | `android/app/debug.keystore` | Development keystore (password: 'android'). Safe for debug, production requires dedicated release keystore. |
