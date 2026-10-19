# Rankearn Authentication & Role Architecture Map

**Intake Date:** 2026-10-19  
**Source Baseline:** `latest-main.zip`  
**Target Identity Provider:** Supabase Auth (`auth.users`) with PostgreSQL Row Level Security (RLS)  
**Security Lead Note:** High-Risk Identity Migration

---

## 1. Inventory of Current Authentication Flows

### A. Authentication Providers & Lifecycle

| Flow | Current Implementation | Target Supabase Implementation | Security Vulnerability in Source | Target Mitigation |
|---|---|---|---|---|
| **Email/Password Signup** | Firebase Auth `createUserWithEmailAndPassword()` + creates Firestore `users/{uid}`. | Supabase Auth `signUp(email, password)` + Postgres trigger on `auth.users` creates `public.profiles`. | Firestore user creation is handled by client; if client network fails or is aborted, auth user exists without profile document. | Atomic Postgres trigger `on_auth_user_created` creates profile in the exact same transaction. |
| **Email/Password Signin** | Firebase Auth `signInWithEmailAndPassword()`. | Supabase Auth `signInWithPassword(email, password)`. | None. | Native secure token storage with automatic session refresh. |
| **Google OAuth Signin** | Web uses Firebase popup `signInWithPopup()`. Android uses `@codetrix-studio/capacitor-google-auth` to get ID token, then `signInWithCredential()`. | Supabase Auth `signInWithOAuth()` on web; `signInWithIdToken()` on Android via Supabase Flutter SDK. | No unified callback handler between platforms; deep links fragile. | Unified Supabase Auth deep link scheme `com.rankearn.app://auth-callback` for Android and HTTPS redirect on web. |
| **Password Recovery** | Firebase Auth `sendPasswordResetEmail()`. | Supabase Auth `resetPasswordForEmail()`. | None. | Custom branded email template with deep link back to app password reset form. |
| **Email Verification** | Firebase Auth `sendEmailVerification()`. Checked via `auth.currentUser.emailVerified`. | Supabase Auth `user.email_confirmed_at`. Global setting toggles enforcement. | Client-side poll interval can be bypassed if user modifies local storage. | RLS policies prevent read/write to private data if `email_confirmed_at` is null and platform setting is active. |
| **Session Persistence** | Firebase Web SDK `indexedDB` cache. | Supabase Flutter `flutter_secure_storage` encrypted local keychain/keystore. | Plain text storage vulnerability on rooted Android devices. | Encrypted keystore storage on native Android. |
| **Account Suspension** | Read from Firestore `users/{uid}.status`. | Supabase `public.profiles.status` + RLS enforcement check. | Client UI renders `SuspendedScreen`, but Firestore rules DO NOT block read/write access for suspended users! | RLS policies include `CHECK (get_user_status(auth.uid()) = 'active')` on all mutations. |

---

## 2. Legacy UID Dependencies & Migration Mapping Plan

### Foreign Key Inventory of Legacy Firebase UIDs

The legacy Firebase UID (alphanumeric string, 28 characters, e.g. `z4NqX2T6oP9...`) is currently stored across 12 distinct entities:
1. `users/{userId}`: Document key and `userId` field.
2. `users/{userId}/unlockedTests/{testId}`: Parent path key.
3. `tests/{testId}`: `createdBy` field.
4. `tests/{testId}/participants/{userId}`: Subcollection document key and `userId` field.
5. `attempts/{attemptId}`: `userId` field.
6. `leaderboard/{entryId}`: `userId` field.
7. `transactions/{txId}`: `userId` field.
8. `topup_requests/{reqId}`: `userId` field.
9. `withdrawal_requests/{reqId}`: `userId` field.
10. `support_tickets/{ticketId}`: Document ID and `userId` field.
11. `feedbacks/{feedbackId}`: `userId` field.
12. `notifications/{notifId}`: `userId` field (or `'global'`).

### Identity Mapping Table Design
Because Supabase Auth exclusively uses UUIDv4 format (`a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11`), legacy Firebase UIDs cannot be directly used as Supabase Auth IDs.

We introduce a dedicated, restricted migration mapping table:

```sql
CREATE TABLE private.migration_firebase_uid_map (
  firebase_uid VARCHAR(128) PRIMARY KEY,
  supabase_uid UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  migrated_email VARCHAR(255) NOT NULL,
  migrated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);
-- Access restricted strictly to service_role; ordinary users cannot read or query this table.
REVOKE ALL ON private.migration_firebase_uid_map FROM anon, authenticated;
```

### Password Continuity & Account Cutover Strategy
1. **Password Hashes:** Firebase Auth uses a proprietary modified Scrypt hash (`signer_key`, `salt_separator`, `rounds`, `mem_cost`). If the Firebase project owner does not export the Scrypt parameters via Firebase CLI (`firebase auth:export --format=json`), existing passwords cannot be imported directly.
2. **Deterministic Account Continuity:**
   - Pre-provision `auth.users` in Supabase using the user's verified email address and assign a temporary random secure password.
   - When an existing user logs in for the first time post-migration, provide a seamless "Activate Password" / "Send One-Click Login Link" (Magic Link) flow.
   - For Google OAuth users, sign-in links seamlessly to the existing email identity without any password requirement.
   - **Account Linking Safety Rule:** Never merge unverified accounts based solely on raw email. Only link when the OAuth provider confirms `email_verified == true`.

---

## 3. Server-Enforced Admin Authorization Model

### Current Critical Vulnerability in Source
In `apps/admin/src/App.tsx` (lines 84-93 & lines 218-223):
```typescript
const handleMakeAdmin = async () => {
  if (!user) return;
  try {
    await updateDoc(doc(db, 'users', user.uid), { role: 'admin' });
    setProfile((prev) => prev ? { ...prev, role: 'admin' } : null);
...
```
Furthermore, in `firestore.rules`:
```
match /users/{userId} {
  allow update: if isAuthenticated() && (isAdmin() || isOwner(userId));
}
```
**Impact:** ANY authenticated user can elevate themselves to Admin by making a single client-side call updating `role: 'admin'`.

### Target Architecture: Separate Protected Role Store

```sql
-- 1. Create strict roles enum
CREATE TYPE public.app_role AS ENUM ('user', 'support', 'admin');

-- 2. Dedicated roles table (NEVER exposed to public or user writes)
CREATE TABLE public.user_roles (
  id BIGSERIAL PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role public.app_role NOT NULL,
  granted_by UUID REFERENCES auth.users(id),
  granted_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
  UNIQUE (user_id, role)
);

-- RLS: Only admins can view; NO client can insert/update/delete directly
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can view roles"
  ON public.user_roles FOR SELECT
  TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.user_roles r
    WHERE r.user_id = auth.uid() AND r.role = 'admin'
  ));

-- 3. Security Definer Authorization Function (fixed search_path)
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
```
