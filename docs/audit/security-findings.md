# Rankearn Security Findings & Vulnerability Report

**Audit Date:** 2026-10-19  
**Auditor:** Senior Authentication & Security Engineer (Phase 0 Audit)  
**Codebase Evaluated:** `latest-main.zip` (`firestore.rules`, `apps/admin/src/App.tsx`, `apps/user/src/components/Wallet.tsx`, `worker/cloudflare_worker.js`)  
**Standard:** OWASP Top 10 API & Mobile Security Standards

---

## Vulnerability Summary Matrix

| Finding ID | Severity | Category | Affected File(s) & Path | Status |
|---|---|---|---|---|
| `SEC-CRIT-01` | **CRITICAL** | Broken Access Control / Privilege Escalation | `apps/admin/src/App.tsx:84-93`, `firestore.rules:113-116` | Confirmed Defect |
| `SEC-CRIT-02` | **CRITICAL** | Financial Integrity / Client Parameter Tampering | `firestore.rules:110-116`, `apps/user/src/components/Wallet.tsx:289-300` | Confirmed Defect |
| `SEC-CRIT-03` | **CRITICAL** | Hardcoded Secrets & Insecure API Proxies | `packages/shared/src/supabase.ts:4`, `apps/user/vite.config.ts:11` | Confirmed Defect |
| `SEC-HIGH-01` | **HIGH** | Insecure Quiz Scoring / Score Forgery | `firestore.rules:145-149`, `worker/cloudflare_worker.js:739-932` | Confirmed Defect |
| `SEC-HIGH-02` | **HIGH** | Unauthenticated File Upload in Cloudflare Worker | `worker/cloudflare_worker.js:349-388`, `400-433` | Confirmed Defect |
| `SEC-HIGH-03` | **HIGH** | Race Condition in Tournament Seat Allocation | `firestore.rules:128-131`, `apps/user/src/components/TournamentJoinModal.tsx` | Confirmed Defect |
| `SEC-MED-01` | **MEDIUM** | Ineffective Account Suspension Enforcement | `firestore.rules:110-122`, `apps/user/src/App.tsx:498` | Confirmed Defect |
| `SEC-MED-02` | **MEDIUM** | Plaintext Token & Session Storage in Web Hybrid | `packages/shared/src/firebase.ts:21-24` | Risk Identified |

---

## Detailed Vulnerability Analysis

### 1. `SEC-CRIT-01`: Client-Side Privilege Escalation to Admin Role

- **Severity:** CRITICAL (CVSS 9.8)
- **Location:** `apps/admin/src/App.tsx:84-93` and `firestore.rules:113-116`
- **Evidence:**
  ```typescript
  // apps/admin/src/App.tsx
  const handleMakeAdmin = async () => {
    if (!user) return;
    try {
      await updateDoc(doc(db, 'users', user.uid), { role: 'admin' });
      setProfile((prev) => prev ? { ...prev, role: 'admin' } : null);
      showToast('Account upgraded to Admin!', 'success');
  ```
  ```firestore
  // firestore.rules
  match /users/{userId} {
    allow update: if isAuthenticated() && (
                    isAdmin() || 
                    isOwner(userId)
                  );
  ```
- **Impact:** Any standard user can open browser developer tools or call the Firestore API directly to set `role: 'admin'`. Once upgraded, the user gains complete read/write access to test questions, user balance adjustments, contest prize disbursements, and platform settings.
- **Recommended Remediation:**
  1. Remove `role` entirely from `public.profiles`.
  2. Implement an isolated `public.user_roles` table protected by RLS where no client has `INSERT`, `UPDATE`, or `DELETE` grants.
  3. Authorize admin actions exclusively via server-side function `is_admin()`.
- **Verification Test:** Automated RLS test attempting an update on `user_roles` as an authenticated non-admin user must return HTTP 403 / Postgres permission denied.

---

### 2. `SEC-CRIT-02`: Client-Controlled Wallet Balance Manipulation

- **Severity:** CRITICAL (CVSS 9.6)
- **Location:** `firestore.rules:110-116`, `apps/user/src/components/Wallet.tsx:289-300`
- **Evidence:**
  `firestore.rules` grants unconditional write permission to the document owner:
  `allow update: if isAuthenticated() && isOwner(userId);`
  The user document stores financial values: `coins`, `withdrawableBalance`, `totalEarned`, `totalSpent`.
- **Impact:** A malicious user can write `{ coins: 1000000, withdrawableBalance: 50000 }` directly to their profile, bypass payment top-ups, unlock all paid test series, and request real currency bank withdrawals.
- **Recommended Remediation:**
  1. In PostgreSQL `public.profiles`, restrict client `UPDATE` policies via RLS with `WITH CHECK` to only allow non-sensitive fields (`name`, `phone`, `state`, `profile_photo_url`, `exam_preparing_for`).
  2. Disallow direct client updates to `coins`, `withdrawable_balance`, `total_earned`, `total_spent`, and `status`.
  3. All coin balance mutations must be executed strictly via transactional PostgreSQL stored procedures (RPCs) that verify business rules and insert an immutable audit record into `public.wallet_transactions`.
- **Verification Test:** Direct SQL / PostgREST `PATCH /rest/v1/profiles` attempting to alter `coins` must be rejected by RLS.

---

### 3. `SEC-CRIT-03`: Hardcoded Anon Keys & Client-Exposed Gemini API Keys

- **Severity:** CRITICAL (CVSS 8.5)
- **Location:** `packages/shared/src/supabase.ts:4`, `apps/user/vite.config.ts:11`
- **Evidence:**
  `apps/user/vite.config.ts`:
  ```typescript
  define: {
    'process.env.GEMINI_API_KEY': JSON.stringify(env.GEMINI_API_KEY),
  }
  ```
- **Impact:** Compiling the frontend bundles the secret `GEMINI_API_KEY` into production JavaScript files, allowing third parties to extract the key, exhaust API quotas, and incur unauthorized billing charges.
- **Recommended Remediation:**
  1. Strip all client-side references to `GEMINI_API_KEY`.
  2. All Gemini AI interactions must route exclusively through trusted server-side Edge Functions (`/functions/v1/generate-ai-test`) where secrets reside in the Supabase Secret Vault.
- **Verification Test:** Search production build bundle (`dist/assets/*.js`) for `GEMINI_API_KEY` or AI Studio keys; zero instances must appear.

---

### 4. `SEC-HIGH-01`: Insecure Quiz Scoring / Score Forgery Risk

- **Severity:** HIGH (CVSS 7.8)
- **Location:** `firestore.rules:145-149`, `worker/cloudflare_worker.js:739-932`
- **Evidence:**
  In `firestore.rules`:
  ```firestore
  match /attempts/{attemptId} {
    allow create: if isAuthenticated() && isValidAttemptCreate(request.resource.data);
  }
  ```
  `isValidAttemptCreate()` verifies that `score` and `accuracy` are numbers, but NEVER validates whether the score matches the actual question answer key!
- **Impact:** Any user can submit a direct `POST` to Firestore claiming a perfect score (e.g. 100/100 in 1 second) and capture top tournament prize money without answering questions correctly.
- **Recommended Remediation:**
  1. Revoke client `INSERT` permissions on `public.attempts`.
  2. Attempts can only be created by Supabase Edge Function `submit-quiz` which fetches correct answers securely from `public.questions`, evaluates correctness server-side, applies negative marking, and writes the verified attempt record.
- **Verification Test:** Attempt submission containing falsified score must be ignored; database must store server-calculated score only.

---

### 5. `SEC-HIGH-02`: Unauthenticated Storage Upload in Edge Worker

- **Severity:** HIGH (CVSS 7.5)
- **Location:** `worker/cloudflare_worker.js:349-388` (`/upload-avatar`), `400-433` (`/upload-quiz-image`)
- **Evidence:**
  ```javascript
  if (request.method === "POST" && url.pathname === "/upload-avatar") {
    const { userId, image } = body;
    // Uses env.SUPABASE_SERVICE_ROLE_KEY to upload without validating Authorization header!
  ```
- **Impact:** An attacker can upload arbitrary binary payloads or overwrite any user's avatar by simply passing an arbitrary `userId` without presenting a valid session token.
- **Recommended Remediation:**
  1. Require a valid Supabase JWT `Bearer <token>` on all upload routes.
  2. Extract `auth.uid` from the verified token and enforce that users can only upload to their own user directory (`avatars/{user_id}.png`).
- **Verification Test:** HTTP `POST` to upload endpoint without `Authorization` header must return HTTP 401 Unauthorized.

---

### 6. `SEC-HIGH-03`: Race Condition in Tournament Seat Allocation

- **Severity:** HIGH (CVSS 7.2)
- **Location:** `apps/user/src/components/TournamentJoinModal.tsx`, `firestore.rules:128-131`
- **Evidence:**
  Firestore client updates `totalParticipants` using increment or transaction, but lacks server-side atomic locking against max seat capacity.
- **Impact:** Multiple users joining simultaneously at capacity can oversell tournament seats beyond limits.
- **Recommended Remediation:**
  Implement PostgreSQL stored procedure `public.join_tournament()` with row-level lock (`SELECT ... FOR UPDATE`) checking `total_participants < max_participants` before deducting coins and adding the participant.
- **Verification Test:** Concurrency test running 20 parallel requests for 1 remaining seat must admit exactly 1 user and reject 19 with "Tournament is full".
