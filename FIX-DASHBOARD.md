# Dashboard visibility fix (manual commit)

## Root cause

Sequential home reveal set non-carousel sections to `opacity: 0` until `HomeRevealCoordinator.currentStep` advanced. Advancement depended on `DashboardRevealModifier` calling `sectionAnimationDidComplete` from `onChange(of: isVisible)` — which does **not** run when `isVisible` is already `true` on first layout. The chain stuck at `.carousel` (carousel visible, everything else invisible).

## What changed

- Removed per-section `.dashboardReveal` gating from `DashboardView`
- Removed `HomeRevealCoordinator` / `tryBeginHomeReveal` from `DashboardViewModel`
- `HomeRevealCoordinator` is a no-op stub (package API preserved)
- Deleted `DashboardRevealModifier.swift`
- Optional whole-block spring (0.92 → 1) when `isDashboardContentReady` becomes true
- README motion section updated

## Suggested commit

```bash
cd PulseLedger
git add Packages/PulseTransactions/Sources/PulseTransactions/DashboardView.swift \
  Packages/PulseTransactions/Sources/PulseTransactions/DashboardViewModel.swift \
  Packages/PulseTransactions/Sources/PulseTransactions/HomeRevealCoordinator.swift \
  README.md FIX-DASHBOARD.md
git rm Packages/PulseTransactions/Sources/PulseTransactions/DashboardRevealModifier.swift 2>/dev/null || \
  git add -u Packages/PulseTransactions/Sources/PulseTransactions/DashboardRevealModifier.swift
git commit -m "Fix blank dashboard by removing sequential reveal gating"
```

## Test steps

1. Build and run on simulator (iPhone 16e / iOS 18.5).
2. Sign in → home loads: carousel, balance, weekly card, chart, transaction stack all visible (skeletons first, then content).
3. Pull to refresh — all sections remain visible; no permanent black gaps.
4. Tap transaction stack → full-screen **Transaction history** (not detail); swipe down or Close returns to collapsed stack.
5. In history, tap a row → full-screen detail (`TransactionDetailTransitionView`); collapsed stack cards do not open detail.
6. Bell icon → test notification still schedules.
