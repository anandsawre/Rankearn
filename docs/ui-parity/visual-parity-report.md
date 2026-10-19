# Rankearn UI Parity & Design System Verification Report

## 1. Visual Source of Truth Baseline

Per **Non-Negotiable Rule 1**, the existing UI in `apps/user` and `apps/admin` serves as the absolute visual source of truth. The Flutter Monorepo migration preserves all layout structures, micro-interactions, spacing metrics, typography scales, Devanagari Hindi text rendering, and semantic status styles.

### Core Design System Tokens (`packages/design_system`)
| Token Category | Legacy React / CSS Token | Flutter Design System Implementation | Parity Status |
| :--- | :--- | :--- | :--- |
| **Brand Primary** | `#10b981` (Emerald 500) | `AppColors.brandPrimary = Color(0xFF10B981)` | **Verified** |
| **Brand Hover/Dark** | `#059669` / `#047857` | `AppColors.brandPrimaryHover` / `AppColors.brandPrimaryDark` | **Verified** |
| **Canvas Background** | `#F8FAF9` | `AppColors.background = Color(0xFFF8FAF9)` | **Verified** |
| **Card Surface** | `#FFFFFF` | `AppColors.surface = Color(0xFFFFFFFF)` | **Verified** |
| **Text Primary** | `#0F172A` (Slate 900) | `AppColors.textPrimary = Color(0xFF0F172A)` | **Verified** |
| **Text Secondary** | `#475569` (Slate 600) | `AppColors.textSecondary = Color(0xFF475569)` | **Verified** |
| **Coin Gold** | `#F59E0B` (Amber 500) | `AppColors.coinGold = Color(0xFFF59E0B)` | **Verified** |
| **Error Rose** | `#F43F5E` (Rose 500) | `AppColors.errorRose = Color(0xFFF43F5E)` | **Verified** |
| **Border Subtle** | `#E2E8F0` (Slate 200) | `AppColors.border = Color(0xFFE2E8F0)` | **Verified** |
| **Border Radius** | `8px`, `12px`, `16px`, `9999px` | `AppRadii.borderMd`, `borderLg`, `borderXl`, `borderPill` | **Verified** |
| **Emerald Shadow** | `0 4px 14px 0 rgba(16, 185, 129, 0.25)` | `AppShadows.emeraldGlow` | **Verified** |
| **Subtle Card Shadow** | `0 1px 3px 0 rgba(0, 0, 0, 0.05)` | `AppShadows.subtle` | **Verified** |

---

## 2. Screen-by-Screen Parity Checklist

### A. Candidate User App (`apps/user_app`)
| Screen / Component | React Source | Flutter Target | Functional & Visual Verification |
| :--- | :--- | :--- | :--- |
| **App Top Header** | `apps/user/src/App.tsx:288-340` | `AppHeader` in `packages/design_system` | Verified: Logo badge, title, coin pill, notification counter, user initial avatar. |
| **Bottom Navigation** | `apps/user/src/App.tsx:350-410` | `AppBottomNav` (6 tabs) | Verified: Home, Tests, Earn, Spin, Wallet, Profile tabs with animated active indicators. |
| **Home Dashboard** | `apps/user/src/components/Dashboard.tsx` | `_UserAppShellState._buildHomeView()` | Verified: Tournament master banner, quick stats, popular test series cards. |
| **Test Catalog** | `apps/user/src/components/TestSeries.tsx` | `_buildTestsView()` & `_buildTestCard()` | Verified: Exam category badges, question counts, duration, negative marking tags. |
| **Quiz Interface** | `apps/user/src/components/QuizInterface.tsx` | `QuizScreen` (`features/quiz/quiz_screen.dart`) | Verified: Full-screen countdown timer, question palette drawer (5 status colors), bilingual toggle, option letters, submission confirmation modal. |
| **Daily Lucky Wheel** | `apps/user/src/components/LuckyWheel.tsx` | `LuckyWheelScreen` (`features/spin/lucky_wheel_screen.dart`) | Verified: Canvas-based physics wheel painter, 8 prize sectors, top pointer, central spin button, reward celebration dialog. |
| **1v1 Battle Arena** | `apps/user/src/components/battle/BattleMain.tsx` | `BattleScreen` (`features/battle/battle_screen.dart`) | Verified: Player vs Opponent scoreboard, 15s turn countdown, instant feedback, victory resolution. |
| **Coin & Cash Wallet** | `apps/user/src/components/Wallet.tsx` | `_buildWalletView()` | Verified: Emerald balance card, coin-to-rupee valuation, top-up modal trigger, withdrawal button, recent transaction list. |
| **User Profile** | `apps/user/src/components/Profile.tsx` | `_buildProfileView()` | Verified: User name, email, Pro badge, account status, logout confirmation. |

---

### B. Admin Management Portal (`apps/admin_app`)
| Screen / Component | React Source | Flutter Target | Functional & Visual Verification |
| :--- | :--- | :--- | :--- |
| **Admin Navigation Rail** | `apps/admin/src/App.tsx:16-35` | `AdminSidebar` (18 items) | Verified: Complete 18-tab sidebar rail with responsive text clipping and logout trigger. |
| **Overview Dashboard** | `apps/admin/src/components/Overview.tsx` | `_buildOverviewTab()` | Verified: Registered users KPI, Published tests KPI, Pending UTRs KPI, quick actions. |
| **Finance & UTR Queue** | `apps/admin/src/components/Finance.tsx` | `_buildFinanceTab()` & `_buildTopupRow()` | Verified: UTR verification table, Approve/Reject actions, coin credit workflow. |
| **Test Series Manager** | `apps/admin/src/components/Tests.tsx` | `_buildTestsTab()` | Verified: Test catalog listing, question count badges, edit actions. |
| **User Directory** | `apps/admin/src/components/Users.tsx` | `_buildUsersTab()` | Verified: User search by email/name, role tags, coin balance adjustment, suspend action. |
| **Contest Scheduler** | `apps/admin/src/components/Contests.tsx` | `_buildContestsTab()` | Verified: Tournament listing, start/end times, entry fee, declare results action. |
| **AI Test Creator** | `apps/admin/src/components/AICreator.tsx` | `_buildAiCreatorTab()` | Verified: Exam name, topic focus, question count, difficulty level, Gemini proxy dispatch. |
| **Wheel Configuration** | `apps/admin/src/components/WheelConfig.tsx` | `_buildWheelConfigTab()` | Verified: 8-sector reward configuration, probability weights, save action. |
| **Push Broadcast Console**| `apps/admin/src/components/Notifications.tsx`| `_buildNotificationsTab()` | Verified: Title, message body, target topic selection (`all_users`), FCM dispatch button. |

---

## 3. Visual Parity Verification Result: PASS
All visual components, colors, spacing scales, and interactions match the React 19 source of truth. No unapproved redesigns or placeholder widgets exist.
