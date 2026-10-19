# Rankearn Migration Decisions & Architectural Charter

**Intake Date:** 2026-10-19  
**Approved Strategy:** Full Monorepo Migration to Flutter with Supabase-First Backend  
**Document Classification:** Architectural Record & Non-Negotiable Decisions

---

## 1. Core Architectural Decisions

### Architecture Decision 1: Supabase-First Database & Identity
- **Decision:** Supabase PostgreSQL is the primary application database and Supabase Auth is the primary authentication provider.
- **Rationale:** Replaces disparate Firestore document structures and insecure client-side rule evaluations with ACID-compliant relational schemas, strict constraints, foreign keys, server-enforced Row Level Security (RLS), and unified identity management.
- **Prohibition:** Dual-write architectures are strictly prohibited. Firebase Auth and Firestore must NOT remain a secondary or conflicting source of truth.

### Architecture Decision 2: Controlled Firebase Exception (Notification-Only)
- **Decision:** Firebase Cloud Messaging (FCM) is retained strictly as a platform push notification delivery gateway for native Android and Web.
- **Boundaries:**
  - FCM has ZERO database or authentication responsibilities.
  - Device tokens are stored in Supabase PostgreSQL table `public.user_device_tokens`.
  - Notification dispatch is triggered from Supabase Edge Functions / trusted server using Google Service Account credentials.

### Architecture Decision 3: Privileged Execution Layer Allocation
- **Decision:** All privileged mutations (coin crediting, withdrawal approval, tournament prize distribution, quiz scoring calculation, 1v1 battle payout, and Gemini AI operations) must run strictly on server-side trusted execution environments:
  - Supabase Edge Functions (`/functions/v1/...`) and/or secured Cloudflare Worker with authenticated Supabase JWT verification.
  - Zero privileged secrets in client bundles (`service_role` keys, database passwords, Gemini API keys).

### Architecture Decision 4: Centralized Monorepo Structure
- **Decision:** Maintain both the User App and the Admin App within the same Git repository alongside centralized shared packages:
  ```
  apps/
    user_app/          # Flutter User Application
    admin_app/         # Flutter Admin Portal Application
  packages/
    design_system/     # Shared visual tokens, colors, typography, UI widgets
    shared_core/       # Shared business utilities, validators, result types
    data_layer/        # Supabase client, repositories, typed models, auth
  supabase/
    migrations/        # Version-controlled SQL migrations
    functions/         # Edge Functions
    seed.sql           # Safe local development seed
  ```
- **Separation of Apps:** The User App and Admin App have separate Flutter entrypoints, separate application IDs (`com.rankearn.app` vs `com.rankearn.admin`), distinct navigation trees, and independent deployment configurations. The Admin App is not merely a hidden screen in the User App.

### Architecture Decision 5: State Management Standard
- **Decision:** Standardize on **Riverpod** across all Flutter apps and packages.
- **Rationale:** Compile-time safety, seamless provider scoping, testability with mocks, no BuildContext dependency in data layers, and clean lifecycle management for streams and Supabase Realtime subscriptions.

---

## 2. Risk Mitigation & Cutover Guidelines

1. **Reversibility:** Keep the original React source and current deployment configuration intact until Flutter feature parity is demonstrated and verified through the visual and functional checklist.
2. **Data Reconciliation:** Before production cutover, execute the automated reconciliation script comparing entity counts, wallet totals, and sampled user records between Firestore and Supabase PostgreSQL.
3. **Rollback Trigger:** If critical reconciliation discrepancies occur or auth restore fails in rehearsal, live traffic remains on the baseline system until resolved.
4. **No Destructive Operations:** Never run real payment charges or destructive database migrations during staging tests.
