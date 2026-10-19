# Rankearn UI Baseline Checklist & Visual Tokens Reference

**Intake Date:** 2026-10-19  
**Source Baseline:** `latest-main.zip` (`apps/user/src/index.css`, `apps/user/src/App.tsx`, `apps/admin/src/App.tsx`)  
**Visual Truth Rule (Non-Negotiable Rule 1):** Do not redesign screens. Preserve layout, spacing, radii, colors, typography, animations, icons, borders, and visible copy.

---

## 1. Core Visual Tokens & Design System Specification

### Color Palette Tokens
| Token Name | Hex Code | Usage in Source | Role |
|---|---|---|---|
| `brand-primary` | `#10b981` (Emerald 500) | Primary buttons, active tabs, header bar, success badges | Brand Identity |
| `brand-primary-hover` | `#059669` (Emerald 600) | Button hover, active borders | Interaction State |
| `brand-primary-dark` | `#047857` (Emerald 700) | Gradient stops, active pressed state | Depth Accent |
| `brand-primary-light` | `#ecfdf5` (Emerald 50) | Background chips, badge containers | Subtle Background |
| `brand-primary-glow` | `rgba(16, 185, 129, 0.25)` | Card shadows, modal glow | Ambient Shadow |
| `bg-app` | `#F8FAF9` | Application background behind all main cards | Main Canvas |
| `surface-white` | `#FFFFFF` | Primary card surfaces, modal sheets | Card Surface |
| `text-primary` | `#0f172a` (Slate 900) | Main headings, bold titles | Typography |
| `text-secondary` | `#475569` (Slate 600) | Subtitles, section headers | Typography |
| `text-muted` | `#94a3b8` (Slate 400) | Captions, timestamps, disabled labels | Typography |
| `border-subtle` | `#e2e8f0` (Slate 200) | Card dividers, input borders | Structure |
| `accent-gold` | `#f59e0b` (Amber 500) | Coins, PRO membership badge, podium gold | Gamification |
| `accent-rose` | `#f43f5e` (Rose 500) | Negative marks, errors, battle health bar | Status / Danger |
| `surface-dark-modal` | `linear-gradient(160deg, #0f172a, #1e293b, #0c1a2e)` | Welcome bonus modal, battle arena | High-Impact Dark Surfaces |

### Typography Scale
- **Font Family:** Modern Sans-Serif (`Inter`, `system-ui`) with full Devanagari (Hindi) Unicode support.
- **Display Bold:** `font-black text-2xl tracking-tight` (Page headers).
- **Section Heading:** `font-bold text-lg text-slate-800`.
- **Card Title:** `font-bold text-sm text-slate-900`.
- **Body Regular:** `text-sm text-slate-600 leading-relaxed`.
- **Badge / Micro Tag:** `text-[10px] font-black uppercase tracking-wider`.

### Corner Radii & Elevation
- **Input & Buttons:** `rounded-xl` (12px) and `rounded-2xl` (16px).
- **Cards & Modals:** `rounded-2xl` (16px) to `rounded-3xl` (24px).
- **Pills / Badges:** `rounded-full` (9999px).
- **Shadow Tokens:**
  - `shadow-sm`: `0 1px 2px 0 rgba(0, 0, 0, 0.05)`
  - `shadow-lg`: `0 10px 15px -3px rgba(0, 0, 0, 0.1)`
  - `shadow-emerald`: `0 8px 24px rgba(16, 185, 129, 0.25)`

---

## 2. Screen-by-Screen Visual Baseline Checklist

### User Application Screens

| Screen / Component | Target Viewports | Key Visual Elements to Verify | Verification Status |
|---|---|---|---|
| **User Header Shell** | Mobile (390w), Tablet (768w), Desktop (1200w) | Emerald background (`#10b981`), white R logo avatar, live coin pill, PRO badge, bell icon. | Checklist Created |
| **Mobile Bottom Nav** | Mobile (390x844) | 6 items: Home, Tests, Earn, Spin, Wallet, Profile. Fixed bottom h-16 blur glassmorphism. | Checklist Created |
| **Dashboard** | Mobile & Tablet | Banner carousel (16:9), 4 quick stat cards, live contest alert, category cards, community poll. | Checklist Created |
| **Test Series Hub** | Mobile & Desktop | Category chip filter, subject pills, test cards (mode badge, duration, question count, unlock button). | Checklist Created |
| **Quiz Interface** | Full Screen (Mobile & Tablet) | Countdown clock, question counter, bilingual toggle, LaTeX math rendering, question palette drawer. | Checklist Created |
| **Test Results** | Mobile & Desktop | Trophy hero card, accuracy circle, score badge, time taken, distribution chart, solution button. | Checklist Created |
| **Review Page** | Mobile & Desktop | Question solutions, green highlight for correct, red for wrong, explanation card in EN/HI. | Checklist Created |
| **Contests / Earn Hub**| Mobile & Desktop | 3-tab layout: Live, Upcoming, Completed. Prize pool badges, countdown timer, Join button. | Checklist Created |
| **1v1 Battle Arena** | Mobile | Stakes selector (10, 50, 100), arena avatar matchup, rapid-fire question card, live health bars. | Checklist Created |
| **Lucky Wheel** | Mobile | 8-slice canvas wheel, center spin button, daily free spin status, coin win confetti modal. | Checklist Created |
| **Wallet** | Mobile | Emerald master card with coin & rupee balance, 3-step UPI topup modal with dynamic QR, withdrawal modal. | Checklist Created |
| **Refer & Earn** | Mobile | Gift box illustration, dashed code box, copy button, WhatsApp and Telegram share actions. | Checklist Created |
| **User Profile** | Mobile | Avatar upload button with camera overlay, personal details form, exam target picker, logout button. | Checklist Created |
| **Auth Modal** | Mobile (360w) | 440px modal with email/password and Google buttons, error toast alerts. | Checklist Created |

### Admin Application Screens

| Screen / Component | Target Viewports | Key Visual Elements to Verify | Verification Status |
|---|---|---|---|
| **Admin Top App Bar** | Desktop (1440w) & Tablet (1024w) | Emerald header bar, Rankearn Admin branding, current active tab label, profile chip, logout. | Checklist Created |
| **Admin Sidebar Rail**| Desktop | 18 navigation items with dedicated Lucide icons and active emerald pill highlights. | Checklist Created |
| **Admin Overview** | Desktop | Metric grid (Users, Revenue, Tests, Attempts), quick action cards, recent activity feed. | Checklist Created |
| **Test Series Manager**| Desktop | Data table with filters, search, status badge, action dropdown, Add Test button. | Checklist Created |
| **Question Editor** | Desktop | Dual-pane bilingual editor (English / Hindi), 4 radio options, LaTeX preview, diagram upload. | Checklist Created |
| **Finance Console** | Desktop | Pending UPI topup requests table with UTR verification, Approve/Reject modals, withdrawal manager. | Checklist Created |
| **Contests Manager** | Desktop | Tournament schedule table, prize distribution editor, participant viewer, result declaration CTA. | Checklist Created |
| **User Directory** | Desktop | Searchable user grid, role pills (user/admin), ban/suspend action dialog, wallet balance editor. | Checklist Created |
| **Notification Center**| Desktop | Broadcast composer with audience selector (All, Pro, Free), live preview card, Send button. | Checklist Created |
| **Helpdesk Console** | Desktop | Two-pane support interface (ticket list on left, active chat messages on right with send box). | Checklist Created |
