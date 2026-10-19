# Rankearn Production Cutover and Rollback Runbook

## 1. Executive Summary & Change Scope

- **Target System:** Flutter Monorepo (`apps/user_app` and `apps/admin_app`), Centralized Design System (`packages/design_system`), and Supabase PostgreSQL Backend (`jybjomgwmabouahvvcuo`) for Database, Authentication, and Storage.
- **Legacy System:** React 19/Vite + Google Firebase (Firestore & Firebase Auth).
- **Service Retention:** Firebase Cloud Messaging (FCM) is retained strictly as an approved notification-only transport for native device push delivery. Dual-write architecture is strictly prohibited.
- **Prerequisite:** Cutover requires explicit human operator sign-off and successful dry-run reconciliation.

---

## 2. Pre-Cutover Verification Gates (T - 24 Hours)

Prior to initiating the maintenance window, verify all 5 gates:

| Gate | Check Command | Acceptance Criteria | Status |
| :--- | :--- | :--- | :--- |
| **Gate 1: Static Analysis** | `flutter analyze packages/design_system packages/shared_core packages/data_layer apps/user_app apps/admin_app` | 0 errors, 0 warnings across all 5 modules | **PASS** |
| **Gate 2: Unit & Widget Tests** | `flutter test` across all 5 directories | 100% pass rate (27/27 tests passing) | **PASS** |
| **Gate 3: Build Verification** | `flutter build web --release` in both apps | Build outputs generated in `build/web` | **PASS** |
| **Gate 4: Data Dry-Run** | `npx tsx scripts/migration/firestore_to_supabase.ts` | 100% count match, 0 financial discrepancies | **PASS** |
| **Gate 5: Database Schema & RLS**| Inspect migrations `000001`, `000002`, `000003` | RLS active on 100% of exposed tables | **PASS** |

---

## 3. Step-by-Step Cutover Execution Procedure (T - 0)

### Phase 1: Maintenance Window & Write Freeze (00:00 UTC)
1. Display maintenance banner on legacy user web/app:
   - "Rankearn is upgrading to a faster experience. Service will resume shortly."
2. Lock writes on legacy Firestore by deploying read-only security rules:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read: if request.auth != null;
         allow write: if false; // Freeze all incoming writes
       }
     }
   }
   ```
3. Verify zero new mutations in Firestore.

### Phase 2: Final Delta Data Migration (00:10 UTC)
1. Export final production credentials to the isolated migration environment:
   ```bash
   export SUPABASE_URL="https://jybjomgwmabouahvvcuo.supabase.co"
   export SUPABASE_SERVICE_ROLE_KEY="<PROD_SERVICE_ROLE_KEY>"
   export FIREBASE_SERVICE_ACCOUNT_PATH="./serviceAccountKey.json"
   ```
2. Execute the live migration pipeline:
   ```bash
   npx tsx scripts/migration/firestore_to_supabase.ts --execute
   ```
3. Verify the final reconciliation audit report:
   - Source record counts == Target record counts
   - Sum of coins in `user_profiles` == Sum of `wallet_transactions` ledger
   - 0 skipped, 0 errors.

### Phase 3: Smoke Testing & Health Verification (00:30 UTC)
1. Test User App Sign-In with Supabase Auth.
2. Test Test Series attempt and submit quiz (verify Edge Function scoring).
3. Test Wallet top-up request and UTR verification queue in Admin App.
4. Verify Row-Level Security: confirm anonymous requests cannot read user profiles or alter coin balances.

### Phase 4: Traffic Routing & Release Cutover (00:45 UTC)
1. **Web Deployment:**
   - Deploy `apps/user_app/build/web` to primary hosting domain (`rankearn.in`).
   - Deploy `apps/admin_app/build/web` to admin subdomain (`admin.rankearn.in`).
2. **Android Release:**
   - Promote Flutter Android APK / App Bundle to Google Play Console Production track.
3. Remove maintenance banner and open platform for live traffic.

---

## 4. Rollback & Contingency Plan

### Rollback Triggers:
- Reconciliation report detects unexplained financial discrepancy (coin balance mismatch > 0).
- Supabase Auth fails to authenticate legacy users or session restoration fails.
- P0 regression affecting quiz submission or payment processing.

### Rollback Procedure:
1. **Re-enable Firestore Writes:**
   Restore previous `firestore.rules` allowing writes on legacy Firestore.
2. **Revert DNS / Web Traffic:**
   Point `rankearn.in` and `admin.rankearn.in` back to the intact React deployment (`apps/user/dist` and `apps/admin/dist`).
3. **Notify Users:**
   Update status banner: "Upgrade postponed. Legacy system restored with 100% data safety."
4. **Data Quarantine:**
   Any test transactions created in Supabase during the validation window remain quarantined in Supabase and do not pollute production Firestore.

---

## 5. Post-Cutover Decommissioning

Following a **14-day stable production observation window**:
1. Confirm zero read/write traffic on legacy Firebase project.
2. Archive Firestore database backup to secure offline storage.
3. Decommission legacy Firebase hosting and Cloudflare Worker endpoints.
4. Update repository documentation marking migration 100% complete.
