# Rankearn Repository Architecture & Monorepo Map

**Intake Date:** 2026-10-19  
**Source Artifact:** `latest-main.zip` (39,540,954 bytes)  
**Extraction Directory:** `d:/Rankearn`  
**Baseline Git Commit:** `chore: baseline intake of latest-main`

---

## 1. Directory Tree & Structural Inventory

```
d:/Rankearn/
├── .firebase/                     # Firebase hosting cache artifacts
├── .firebaserc                    # Firebase project definition (default: "rankearn")
├── .github/workflows/             # CI/CD Workflows
│   └── android-build.yml          # Android build workflow using Capacitor
├── .vscode/settings.json          # IDE workspace configurations
├── android/                       # Capacitor-generated Android native application project
│   ├── app/
│   │   ├── build.gradle           # Android app build configuration (appId: com.rankearn.app)
│   │   ├── google-services.json   # Google services config for Firebase FCM & Google Auth
│   │   └── src/                   # Android native manifest, Java/Kotlin code, assets
│   └── build.gradle               # Root Android gradle configuration
├── apps/
│   ├── user/                      # Web/Mobile User Client Application
│   │   ├── src/                   # React 19 + TypeScript + Vite + Tailwind 4
│   │   │   ├── components/        # User UI components (Dashboard, TestSeries, Quiz, Wallet, etc.)
│   │   │   ├── services/          # Gemini AI services
│   │   │   ├── utils/             # Re-exports / utils (attemptStats, push, examCategories)
│   │   │   ├── App.tsx            # Main User router & layout shell (1,528 lines)
│   │   │   ├── firebase.ts        # Client Firebase App & Firestore initialization
│   │   │   ├── index.css          # User styling and Tailwind tokens
│   │   │   ├── main.tsx           # User application entry point
│   │   │   ├── supabase.ts        # Hardcoded Supabase client initialization
│   │   │   └── types.ts           # Re-exports from @rankearn/shared
│   │   ├── package.json           # User app dependencies & scripts (port 3000)
│   │   ├── tsconfig.json
│   │   └── vite.config.ts
│   └── admin/                     # Web Admin Portal Application
│       ├── src/
│       │   ├── components/        # Admin UI components
│       │   │   ├── AdminPanel.tsx # Core monolithic Admin workspace (10,769 lines)
│       │   │   ├── AdminBattleQuestions.tsx # Battle question management (1,117 lines)
│       │   │   ├── AdminFeedback.tsx        # User feedback & ratings (165 lines)
│       │   │   ├── AdminSupport.tsx         # Live Support Ticket Chat (670 lines)
│       │   │   └── [shared user duplicates]
│       │   ├── App.tsx            # Admin portal router, tab navigation, auth gate (383 lines)
│       │   ├── firebase.ts
│       │   ├── index.css
│       │   ├── main.tsx           # Admin application entry point
│       │   ├── supabase.ts
│       │   └── types.ts
│       ├── package.json           # Admin app dependencies & scripts (port 3001)
│       ├── tsconfig.json
│       └── vite.config.ts
├── packages/
│   └── shared/                    # Shared core TypeScript package
│       ├── src/
│       │   ├── firebase.ts        # Centralized Firebase initialization
│       │   ├── index.ts           # Package barrel re-export
│       │   ├── supabase.ts        # Shared Supabase client configuration
│       │   ├── types.ts           # Canonical TypeScript interfaces & data contracts
│       │   └── utils/             # Business logic utilities
│       │       ├── attemptStats.ts      # Score, accuracy, time, negative marking computation
│       │       ├── examCategories.ts    # Normalization & hierarchy for exams
│       │       ├── imageCompressor.ts   # Canvas-based client image compression
│       │       ├── mathMarkdown.ts      # KaTeX / LaTeX math formatting
│       │       ├── push-notifications.ts# Push registration & FCM token storage
│       │       ├── referral.ts          # Referral code generation & validation
│       │       ├── shareUtils.ts        # Web Share API & clipboard fallback
│       │       └── textFormat.ts        # Text title casing & helpers
│       ├── package.json
│       └── tsconfig.json
├── src/                           # LEGACY ROOT DIRECTORY (Redundant pre-monorepo duplicate)
│   ├── components/                # Contains full mixed user + admin components
│   ├── App.tsx                    # Pre-split monolithic application
│   └── [same files as apps/user]
├── worker/                        # Cloudflare Worker Serverless Backend
│   ├── cloudflare_worker.js       # Privileged backend endpoints (1,198 lines)
│   └── README.md                  # Deployment and environment documentation
├── public/                        # Static web assets, PWA manifest, service workers
│   ├── firebase-messaging-sw.js   # Background push notification handler
│   ├── manifest.json              # Web app manifest
│   ├── sw.js                      # Service worker cache
│   └── icons/
├── scripts/                       # Operational & administrative scripts
│   ├── count_cats.ts              # Category verification script
│   └── setAdminClaim.ts           # Firebase Admin SDK custom claim script
├── capacitor.config.ts            # Capacitor mobile bridge configuration
├── firebase.json                  # Firebase hosting, firestore rules and index configuration
├── firestore.rules                # Active Firestore security rules (351 lines)
├── firestore.indexes.json         # Firestore composite indexes (10 indexes)
├── package.json                   # Root monorepo workspace definition
├── package-lock.json              # NPM dependency lockfile
├── vite.config.ts                 # Root vite config
└── tsconfig.json                  # Root TypeScript project references
```

---

## 2. Source-of-Truth & Code Duplication Analysis

During intake, a major structural duplication was identified between the root `src/` directory and `apps/`:

| Directory | Role in Intake | Source of Truth Assessment | Notes |
|---|---|---|---|
| `root src/` | Legacy Pre-Split Monolith | **Obsolete / Duplicate** | Contains pre-split monolithic code where `AdminPanel.tsx` (10,783 lines) and User components coexisted in a single bundle. |
| `apps/user/` | Modern User Client | **Source of Truth for User** | Standalone React client configured with Vite workspace. Imports types and utils from `@rankearn/shared`. Excludes admin modules. |
| `apps/admin/` | Modern Admin Client | **Source of Truth for Admin** | Dedicated Admin portal on port 3001. Features role-based layout, sidebar tabs, and administrative actions. |
| `packages/shared/` | Shared Library | **Source of Truth for Contracts** | Contains data interfaces (`types.ts`), utilities, and shared configurations. |
| `worker/` | Cloudflare Worker | **Source of Truth for Privileged Backend** | Implements privileged operations: Gemini proxy, quiz submission scoring, 1v1 battle payout resolution, avatar/quiz image upload to Supabase, FCM topic/token push. |

**Decommissioning Note:** `root src/` is maintained without modification to satisfy Non-Negotiable Rule 5 until migration verification is complete.

---

## 3. Technology Stack Inventory

### Frontend (Existing Web / Hybrid)
- **Framework:** React 19.0.0
- **Language:** TypeScript ~5.8.2
- **Build Tool:** Vite 6.2.0 (`@tailwindcss/vite` 4.1.14)
- **Styling:** Tailwind CSS 4.x, Vanilla CSS (`index.css`), Motion (`motion/react` 12.23.24)
- **Icons:** `lucide-react` 0.546.0
- **Routing:** `react-router-dom` 7.13.1
- **Math/Rich Text:** `katex` 0.16.38, `react-markdown` 10.1.0, `remark-math` 6.0.0, `rehype-katex` 7.0.1, `react-quill-new` 3.8.3
- **Charts:** `recharts` 3.8.0
- **Exporting/Graphics:** `jspdf` 4.2.0, `docx` 9.6.1, `html2canvas` 1.4.1, `canvas-confetti` 1.9.4, `qrcode.react` 4.2.0

### Mobile Hybrid Bridge
- **Platform:** Capacitor 8.3.1 (`@capacitor/android`, `@capacitor/core`, `@capacitor/cli`)
- **Plugins:** `@capacitor/app`, `@capacitor/push-notifications`, `@capacitor/share`, `@capacitor/splash-screen`, `@codetrix-studio/capacitor-google-auth`

### Backend & Cloud Services
- **Firebase (Legacy):** Firebase Web SDK 12.13.0, Firestore, Firebase Auth, Firebase Cloud Messaging (FCM), Firebase Admin SDK 13.7.0. Project ID: `rankearn`.
- **Supabase (Target Backend & Existing Asset Storage):** `@supabase/supabase-js` 2.103.3. Project: `jybjomgwmabouahvvcuo`. Storage buckets: `avatars`, `quiz-images`, `notification-images`.
- **Cloudflare Worker:** Serverless Edge execution layer for Gemini AI, server-side scoring, bot battles, push delivery.
- **AI Engine:** `@google/genai` 1.29.0 via Gemini 1.5 Flash.

---

## 4. Target Flutter Monorepo Alignment Map

The target Flutter monorepo directly preserves the logical boundaries while centralizing UI design tokens and shared data layers:

```
d:/Rankearn/
├── apps/
│   ├── user_app/                  # Flutter User Application (Android & Web targets)
│   └── admin_app/                 # Flutter Admin Application (Web & Desktop/Tablet targets)
├── packages/
│   ├── design_system/             # Centralized design system (Tokens, Theme, UI Primitives)
│   ├── shared_core/               # Shared logic (Result, Errors, Formatters, Validators)
│   └── data_layer/                # Supabase repositories, Auth service, Realtime, Models
├── supabase/
│   ├── migrations/                # Version-controlled SQL migrations
│   ├── functions/                 # Supabase Edge Functions (mirroring/migrating Worker)
│   └── seed.sql                   # Safe local seed dataset
└── docs/                          # Comprehensive audit and migration runbooks
```
