# PulseLedger animation commits (manual)

Run these in order from `PulseLedger/`. **Do not squash** if you want reviewable history.

## 1. Home reveal coordinator

```bash
git add Packages/PulseTransactions/Sources/PulseTransactions/HomeRevealCoordinator.swift
git add Packages/PulseTransactions/Sources/PulseTransactions/DashboardRevealModifier.swift
git commit -m "Add HomeRevealCoordinator for sequential dashboard reveals"
```

## 2. Wire reveal into dashboard VM + view

```bash
git add Packages/PulseTransactions/Sources/PulseTransactions/DashboardViewModel.swift
git add Packages/PulseTransactions/Sources/PulseTransactions/DashboardView.swift
git commit -m "Sequence home sections after load with spring stagger"
```

## 3. Transaction stack view model

```bash
git add Packages/PulseTransactions/Sources/PulseTransactions/TransactionStackViewModel.swift
git commit -m "Add TransactionStackViewModel with expand/collapse and pagination"
```

## 4. Notification-style stack UI

```bash
git add Packages/PulseTransactions/Sources/PulseTransactions/TransactionStackView.swift
git commit -m "Replace flat list with stacked notification-style transaction cards"
```

## 5. Integrate stack on dashboard

```bash
git add Packages/PulseTransactions/Sources/PulseTransactions/DashboardView.swift
git add Packages/PulseTransactions/Sources/PulseTransactions/DashboardViewModel.swift
git commit -m "Integrate expanded stack overlay and remove NavigationLink list"
```

## 6. Custom transaction detail transition

```bash
git add Packages/PulseTransactions/Sources/PulseTransactions/TransactionDetailTransitionView.swift
git add Packages/PulseTransactions/Sources/PulseTransactions/DashboardView.swift
git commit -m "Present transaction detail via fullScreenCover hero transition"
```

## 7. VIP detail kept for architecture

```bash
git add Packages/PulseTransactions/Sources/PulseTransactions/TransactionDetailVIP.swift
git commit -m "Keep VIP presenter/interactor; navigation push deprecated on home"
```

## 8. README motion section

```bash
git add README.md
git commit -m "Document motion and interaction patterns in README"
```

## 9. Commit guide

```bash
git add COMMITS-ANIMATIONS.md
git commit -m "Add manual commit guide for animation phases"
```

## Verify build

```bash
rm -rf Packages/*/.swiftpm
xcodegen generate
xcodebuild -project PulseLedger.xcodeproj -scheme PulseLedger \
  -destination 'platform=iOS Simulator,name=iPhone 16e,OS=18.5' build
```

## 10. Transaction stack → full-screen history (manual)

**Problem:** Partial ZStack overlay, `matchedGeometryEffect`, and per-card buttons opened detail from the collapsed stack; `ScrollView.allowsHitTesting(false)` while expanded blocked reliable expand.

**Fix:**
- `StackMode` (`collapsed` | `history`) on `TransactionStackViewModel` with `expandToHistory()` / `collapseToStack()` (spring 0.4 / 0.88).
- Collapsed stack: single container tap only; preview cards `allowsHitTesting(false)` (no detail).
- `TransactionHistoryView` presented via `.fullScreenCover` from `DashboardView`; row tap → detail cover.
- Removed `matchedGeometryEffect` and `TransactionStackExpandedOverlay`.

```bash
git add Packages/PulseTransactions/Sources/PulseTransactions/TransactionStackView.swift \
  Packages/PulseTransactions/Sources/PulseTransactions/TransactionStackViewModel.swift \
  Packages/PulseTransactions/Sources/PulseTransactions/DashboardView.swift \
  FIX-DASHBOARD.md COMMITS-ANIMATIONS.md
git commit -m "Present transaction history full-screen; detail only from history rows"
```

## 11. Nested fullScreenCover + slow stack tap (manual)

**Problem:** Tapping a history row set `selectedTransaction` on `DashboardView` while history was already a `.fullScreenCover`, triggering “Currently, only presenting a single sheet is supported.” Collapsed stack tap wrapped `expandToHistory()` in a spring animation and ran haptics on the main thread before presentation, making expand feel sluggish.

**Fix:**
- Removed dashboard `.fullScreenCover(item:)` for detail; only one cover remains (history).
- `TransactionHistoryView` pushes `TransactionDetailTransitionView` via `NavigationStack` + `.navigationDestination(item:)` (hidden nav bar; custom back in detail).
- Collapsed stack: single `Button` + `contentShape(Rectangle())`; `expandToHistory()` sets `mode = .history` immediately (no pre-cover spring).
- Haptics fire in `Task { @MainActor in … }` after state change; history dismiss no longer wraps `collapseToStack()` in spring.

```bash
git add Packages/PulseTransactions/Sources/PulseTransactions/DashboardView.swift \
  Packages/PulseTransactions/Sources/PulseTransactions/TransactionStackView.swift \
  COMMITS-ANIMATIONS.md
git commit -m "Push transaction detail inside history; instant stack expand"
```
