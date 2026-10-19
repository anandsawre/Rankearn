# Rankearn Route & Navigation Map

**Intake Date:** 2026-10-19  
**Source Baseline:** `latest-main.zip`  
**Apps Analyzed:** `apps/user` and `apps/admin`  
**Target Architecture:** Monorepo containing `apps/user_app` and `apps/admin_app` with dedicated GoRouter / AutoRoute navigators.

---

## 1. User Application Route & Navigation Map

### Web / Deep-Link URL Routes

| Path | Screen / Component | Route Guard / Prerequisite | Header Title / Action | Navigation Presentation | Description & URL Parameters |
|---|---|---|---|---|---|
| `/` | `Dashboard.tsx` | None (Guest preview allowed) | Rankearn Logo + Coins + Profile | Main Tab (Home) | Home screen with banners, stats, live contests, recommendations, poll. |
| `/dashboard` | `Dashboard.tsx` | None | Rankearn Logo + Coins + Profile | Main Tab (Home) | Alias for `/`. |
| `/tests` | `TestSeries.tsx` | None | "Test Series" + Search | Main Tab (Tests) | Catalog of tests with exam category filter, subject tabs, search, and mode filter. |
| `/earn` | `Earn.tsx` | None | "Contests & Earn" | Main Tab (Earn) | Contest Hub default view (Live tournaments tab). |
| `/earn/:tab` | `Earn.tsx` | None | "Contests & Earn" | Tab Switch | `:tab` can be `live`, `upcoming`, `past`, `leaderboard`. |
| `/leaderboard` | Redirect -> `/earn/leaderboard` | None | - | Redirect | Legacy route redirected to Earn leaderboard tab. |
| `/battle` | `BattleMain.tsx` | Auth required (opens `AuthModal` if guest) | "1v1 Battle" | Feature View | Rapid-fire multiplayer quiz lobby with stakes selection. |
| `/battle/:inviteId` | `BattleMain.tsx` | Auth required | "1v1 Battle Challenge" | Deep Link Entry | Direct battle invitation link from peer challenge. |
| `/wheel` | `LuckyWheel.tsx` | Auth required | "Lucky Wheel" | Main Tab (Spin) | Daily coin reward wheel with physics and sounds. |
| `/wallet` | `Wallet.tsx` | Auth required | "Wallet" | Main Tab (Wallet) | Coin balance, top-up QR flow, withdrawal request, transaction list. |
| `/refer` | `ReferralSection.tsx` | Auth required | "Refer & Earn" | Action Page | Unique referral code, sharing buttons, and referral rewards breakdown. |
| `/subscription` | `Subscription.tsx` | Feature flag `showSubscriptionTab` | "Rankearn PRO" | Action Page | PRO membership benefits, pricing, and unlock options. |
| `/profile` | `Profile.tsx` | Auth required | "Profile" | Main Tab (Profile) | User avatar, name, exam preferences, state, edit form, logout button. |
| `/results/:attemptId` | `ResultsPage.tsx` | Auth required | "Test Results" | Result Screen | Final score, accuracy, rank, time taken, analytics chart, review CTA. |
| `/review/:attemptId` | `ReviewPage.tsx` | Auth required | "Solutions & Review" | Review Screen | Question-by-question review with filters: all, correct, incorrect, skipped. |
| `/updates` | `Updates.tsx` | None | "Official Updates" | Content Hub | Current affairs and platform updates feed. |
| `/updates/:slug` | `Updates.tsx` | None | "Official Updates" | Article View | Full-length article reader with rich text formatting. |
| `/support` | `SupportChat.tsx` | Auth required | "Support Chat" | Support Screen | Live chat conversation with support agents. |
| `/feedback` | `Feedback.tsx` | Auth required | "Give Feedback" | Feedback Form | 5-star rating and user comment input form. |
| `/privacypolicy` | `PrivacyPolicy.tsx` | None | "Privacy Policy" | Legal Layout | Official privacy policy disclosure. |
| `/termsofuse` | `TermsOfUse.tsx` | None | "Terms of Use" | Legal Layout | User agreement and terms. |
| `/refundpolicy` | `RefundPolicy.tsx` | None | "Refund Policy" | Legal Layout | Coin and payment refund guidelines. |
| `/contactus` | `ContactUs.tsx` | None | "Contact Us" | Legal Layout | Support email, contact channels, and office location. |
| `/aboutus` | `AboutUs.tsx` | None | "About Us" | Legal Layout | Platform mission and background. |
| `/admin` | Redirect -> `/dashboard` | Normal users blocked | - | Security Redirect | Prevents admin leakage in user client. |

---

### User Application Modal & Full-Screen Overlays

| Modal / Overlay | Trigger Condition | Presentation Mode | Dismiss / Exit Behavior |
|---|---|---|---|
| `AuthModal` | Guest clicks action requiring login or `?join=` query param | 440px rounded backdrop modal | Backdrop tap or 'X' button. |
| `VerifyEmailScreen` | User logged in with unverified email and `requireEmailVerification == true` | Full-screen replacement | Logout button or polling on email verification. |
| `SuspendedScreen` | User profile has `status == 'suspended' \|\| 'banned'` | Full-screen locked barrier | Logout only; blocks all app navigation. |
| `WelcomeBonusModal` | New user signs up and is awarded welcome bonus coins | 360px celebration modal with confetti | "Start Learning" CTA button. |
| `ImageBannerModal` | Scheduled high-priority promotional announcement active | Rounded image pop-up modal | Backdrop tap or 'X' button; records click metric. |
| `TournamentJoinModal` | User clicks "Join Contest" on live/upcoming tournament card | Bottom sheet / modal | "Cancel" or "Confirm & Pay Entry Fee". |
| `TestPurchaseModal` | User clicks locked premium test series | Coin checkout modal | "Unlock with Coins" or "Close". |
| `QuizInterface` | `activeTest` state is set (User begins test attempt) | Full-screen exam simulation mode | "Submit Test" or hardware back confirmation. |
| `LiveTestAlert` | Contest is live right now and user is on dashboard | Floating sticky banner at top | "Join Now" CTA button. |
| `NotificationCenter` | User taps bell icon in top header | Right-side slide-over drawer | Close drawer or tap outside. |
| `Battle Exit Guard` | User attempts to navigate away while battle is active | Confirmation modal | "Stay & Win" or "I Understand, Leave" (forfeits coins). |

---

## 2. Admin Application Route & Tab Map

The Admin portal uses a full-screen desktop dashboard layout with a sticky top app bar and an 18-tab side navigation rail.

### Admin Authentication & Access Control States

1. **Unauthenticated:** Shows `Admin Login` form (Email/Password & Google Login).
2. **Logged In but Non-Admin:** Displays `Admin Privilege Needed` screen with user email and warning.
3. **Authorized Admin:** Renders full `AdminPanel` workspace with active tab view.

### Admin Workspace Navigation Tabs

| Tab ID | Tab Label | Lucide Icon | Core Component & Capabilities |
|---|---|---|---|
| `overview` | Overview | `LayoutDashboard` | High-level metrics: Users, Tests, Attempts, Revenue, live tournaments. |
| `tests` | Test Series | `BookOpen` | Test series CRUD, Question management, bilingual questions, options, images. |
| `users` | Users | `Users` | User search by name/email/phone, status filters, ban/unban, role update. |
| `patterns` | Exam Patterns | `Layout` | AI pattern definitions (Sections, subjects, duration, negative markings). |
| `ai-creator` | AI Test Creator | `BrainCircuit` | Gemini 1.5 Flash automated question generation pipeline. |
| `finance` | Finance | `IndianRupee` | UPI top-up verification, withdrawal payouts, manual coin adjustments, ledger. |
| `contests` | Contests | `Trophy` | Tournament scheduler, participant list, prize pool, result declaration. |
| `banners` | Banners | `ImageIcon` | App banner carousel manager, upload, target route, priority. |
| `notifications`| Notifications | `Bell` | Push notification broadcaster with audience segmentation (All, Pro, Free). |
| `wheel` | Lucky Wheel | `RotateCcw` | 8-slice wheel reward configuration (coin values, colors, probabilities). |
| `leaderboard` | Leaderboard | `BarChart3` | Global and test-wise leaderboard inspector. |
| `referrals` | Referrals | `Gift` | Referral reward parameters (referrer coins, referee coins, commission). |
| `posts` | Updates | `FileText` | ReactQuill rich-text publisher for official announcements and current affairs. |
| `support` | Support Chat | `MessageCircle` | Two-pane live helpdesk console for resolving user support tickets. |
| `feedback` | Give Feedback | `Star` | User feedback list, satisfaction ratings, and sentiment review. |
| `battle_qs` | Battle Questions | `Swords` | Rapid-fire 1v1 battle question bank CRUD. |
| `polls` | Community Polls | `Radio` | Interactive community poll creator with expiration date. |
| `settings` | Settings | `Settings` | Payment UPI details, withdrawal limits, email verification toggle, stakes. |

---

## 3. Native & Platform Navigation Behaviors

### Hardware Back Button Handling
- In standard browsing, executes `window.history.back()`.
- If on root route (`/dashboard`), prompts or exits app via Capacitor `App.exitApp()`.
- If inside `QuizInterface`, triggers exit confirmation dialog so users do not accidentally abandon ongoing exams.
- If inside `BattleMain`, triggers battle forfeit guard modal.

### Push Notification Click Handling
- Listens for `push-notification-click` window event.
- Extracts `detail.url` or `actionUrl` and executes programmatic navigation.

### Deep Linking Handling
- Listens for `appUrlOpen` event from Capacitor.
- Parses path and parameters (e.g. `com.rankearn.app://battle/INVITE_ID` or `https://rankearn.com/tests?ref=CODE`).
- Extracts referral code `?ref=CODE` and caches it in auth state for attribution.
