# Rankearn Build & Dependency Findings

**Audit Date:** 2026-10-19  
**Source Baseline:** `latest-main.zip`  
**Host Environment:** Windows (PowerShell), Node v26.3.0, npm 11.16.0, Flutter 3.44.5 (stable), Dart 3.12.2, Supabase CLI 2.109.1

---

## 1. Baseline Build Execution Results

The baseline build command was executed across the entire monorepo workspaces:
`npm run build:all` -> `npm run build --workspaces`

| Workspace | Target Script | Output Status | Build Duration | Artifacts Generated |
|---|---|---|---|---|
| `packages/shared` | `tsc --noEmit` | **PASS (0 errors)** | 2.1s | Verified typecheck |
| `apps/admin` | `vite build` | **PASS** | 22.63s | `dist/` bundle (3,313.97 kB JS, KaTeX fonts) |
| `apps/user` | `vite build` | **PASS** | 17.63s | `dist/` bundle (2,221.63 kB JS, KaTeX fonts, CSS) |

### Baseline Lint & Typecheck Commands
- `npm run lint --workspace=apps/user`: `tsc --noEmit` -> PASS (0 type errors).
- `npm run lint --workspace=apps/admin`: `tsc --noEmit` -> PASS (0 type errors).
- `ts_errors.txt` in root is empty (0 bytes).

---

## 2. Dependency Audit & Health Check

`npm audit` results on baseline install:
- Total packages: 710 packages installed.
- Vulnerabilities identified: 39 vulnerabilities (8 low, 11 moderate, 16 high, 4 critical).
  - Deprecated dependencies: `lodash.isequal@4.5.0`, `node-domexception@1.0.0`, `glob@10.5.0`.
  - Heavy chunk sizes: Both admin and user JS bundles exceed 2 MB uncompressed due to monolithic embedding of `AdminPanel.tsx` (10,769 lines) and heavy third-party web libraries (`jspdf`, `docx`, `katex`, `recharts`, `react-quill-new`).

---

## 3. Flutter Toolchain Readiness

Verification of native Flutter toolchain on system:
- **Flutter Version:** 3.44.5 • channel stable
- **Dart Version:** 3.12.2 (stable) on windows_x64
- **Supabase CLI:** 2.109.1
- **Git Version:** 2.54.0.windows.1

All compilers and toolchains required for the target Flutter User App and Flutter Admin App are installed and ready.
