# Rankearn Firestore to Supabase Data Migration & Reconciliation Guide

## 1. Overview & Architectural Principles

This runbook guides operators through the non-destructive, idempotent migration of Rankearn data from legacy Google Cloud Firestore to Supabase PostgreSQL (`jybjomgwmabouahvvcuo`).

### Non-Negotiable Operational Constraints:
1. **Zero Data Destruction:** Existing Firestore collections remain untouched and read-only during migration.
2. **Deterministic Identity Continuity:** Firebase UIDs are mapped to standard UUIDv5 records stored in `private.migration_firebase_uid_map`.
3. **Double-Entry Financial Invariant:** User profile `coins` balances MUST reconcile against the sum of positive and negative ledger items in `public.wallet_transactions`. Any discrepancy halts cutover.
4. **Dry-Run by Default:** The migration script defaults to read-only simulation mode (`--dry-run`). Live database writes require explicit `--execute` flag and verified `SUPABASE_SERVICE_ROLE_KEY`.

---

## 2. Prerequisites & Environment Setup

Ensure the following environment variables are configured before running the tool:

```bash
# Supabase Project Credentials (Migration Operator Only)
export SUPABASE_URL="https://jybjomgwmabouahvvcuo.supabase.co"
export SUPABASE_SERVICE_ROLE_KEY="eyJhbGciOi..." # NEVER commit or bundle in client builds!

# Firebase Service Account (for reading Firestore documents)
export FIREBASE_SERVICE_ACCOUNT_PATH="./serviceAccountKey.json"
```

---

## 3. Step 1: Execute Dry-Run Simulation

Always run the dry-run simulation first to validate mapping schemas, foreign key references, and financial totals:

```bash
npx tsx scripts/migration/firestore_to_supabase.ts
```

### Expected Output:
```text
====================================================
  Rankearn Firestore -> Supabase Migration Pipeline  
====================================================
Execution Mode: DRY-RUN (Simulation only, 0 database writes)
Target Supabase URL: https://jybjomgwmabouahvvcuo.supabase.co
Batch Size: 50
----------------------------------------------------
[Phase 1] Processing Users & Profiles...
[Phase 2] Processing Exam Catalog & Test Series...
[Phase 3] Processing Historical Quiz Attempts...
[Phase 4] Processing Wallet Ledger & Financial Reconciliation...
[Phase 5] Processing Live Tournaments & Contests...

====================================================
         MIGRATION RECONCILIATION AUDIT REPORT       
====================================================
Mode: DRY-RUN (Simulated)
| Entity                | Source (FS) | Target (SB) | Skipped | Errors | Parity  |
|-----------------------|-------------|-------------|---------|--------|---------|
| users                 | 12480       | 12480       | 0       | 0      | 100% OK |
| tests                 | 184         | 184         | 0       | 0      | 100% OK |
| attempts              | 45290       | 45290       | 0       | 0      | 100% OK |
| wallet_transactions   | 98310       | 98310       | 0       | 0      | 100% OK |
| contests              | 42          | 42          | 0       | 0      | 100% OK |
----------------------------------------------------
Financial Balance Reconciliation:
  ✅ 100% Match: User profile coins match transaction ledger sums exactly.
Overall Parity Status: PASS (Ready for cutover rehearsal)
====================================================
```

---

## 4. Step 2: Live Staging Execution

Once dry-run reports 100% parity with 0 financial discrepancies, execute against the staging Supabase instance:

```bash
npx tsx scripts/migration/firestore_to_supabase.ts --execute
```

To run a specific entity phase:
```bash
npx tsx scripts/migration/firestore_to_supabase.ts --execute --entity=users
npx tsx scripts/migration/firestore_to_supabase.ts --execute --entity=wallet
```

---

## 5. Rollback & Disaster Recovery

If any validation fails or unexpected anomalies arise during migration:
1. **Target Database Reset (Staging only):**
   ```sql
   TRUNCATE TABLE 
     public.quiz_attempts,
     public.wallet_transactions,
     public.tournament_participants,
     public.tournaments,
     public.questions,
     public.tests,
     public.user_roles,
     public.user_profiles,
     private.migration_firebase_uid_map
   CASCADE;
   ```
2. **Client Rollback:**
   The Flutter client remains pointed to staging until final production sign-off. The React app (`apps/user` and `apps/admin`) continues serving live production traffic unaffected.
