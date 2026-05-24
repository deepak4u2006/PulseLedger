#!/bin/bash
# Run from PulseLedger folder. One commit per block — copy/paste each block separately.
# Optional: chmod +x COMMIT-COMMANDS.sh  (do NOT run whole script at once unless you want all commits in one go)

cd "$(dirname "$0")"

# 0 — regenerate Xcode project after commit 13 (run when you reach commit 13)
# xcodegen generate

# --- 1 ---
git add Packages/PulseCore/Package.swift \
  Packages/PulseDesign/Package.swift \
  Packages/PulseNetworking/Package.swift \
  Packages/PulseSecurity/Package.swift \
  Packages/PulseNotify/Package.swift \
  Packages/PulseBridge/Package.swift \
  Packages/PulseAuth/Package.swift \
  Packages/PulseTransactions/Package.swift
git commit -m "chore: scaffold local SPM package layout"

# --- 2 ---
git add Packages/PulseCore/
git commit -m "feat(core): add PulseCore domain and mock API"

# --- 3 ---
git add Packages/PulseDesign/Sources/PulseDesign/FintechTheme.swift \
  Packages/PulseDesign/Sources/PulseDesign/SkeletonView.swift \
  Packages/PulseDesign/Sources/PulseDesign/OfflineBanner.swift
git commit -m "feat(design): add FintechTheme and skeleton components"

# --- 4 ---
git add Packages/PulseDesign/Sources/PulseDesign/MagneticCardCarousel.swift \
  Packages/PulseDesign/Sources/PulseDesign/AnimationHelpers.swift \
  Packages/PulseDesign/Sources/PulseDesign/Haptics.swift \
  Packages/PulseDesign/Package.swift
git commit -m "feat(design): add magnetic card carousel and motion helpers"

# --- 5 ---
git add Packages/PulseNetworking/
git commit -m "feat(networking): add NWPathMonitor reachability"

# --- 6 ---
git add Packages/PulseSecurity/
git commit -m "feat(security): add Keychain session and biometric gate"

# --- 7 ---
git add Packages/PulseNotify/
git commit -m "feat(notify): add payment notification center"

# --- 8 ---
git add Packages/PulseBridge/
git commit -m "feat(bridge): add UIKit category spend bar chart"

# --- 9 ---
git add Packages/PulseAuth/
git commit -m "feat(auth): add MVVM-C auth flow with Lottie success"

# --- 10 ---
git add Packages/PulseTransactions/Sources/PulseTransactions/DashboardViewModel.swift \
  Packages/PulseTransactions/Sources/PulseTransactions/DashboardView.swift
git commit -m "feat(transactions): add dashboard MVVM with staggered API"

# --- 11 ---
git add Packages/PulseTransactions/Sources/PulseTransactions/TransactionDetailVIP.swift \
  Packages/PulseTransactions/Package.swift
git commit -m "feat(transactions): add transaction detail VIP module"

# --- 12 ---
git add PulseLedger/PulseLedgerApp.swift PulseLedger/App/
git add -u PulseLedger/
git commit -m "refactor(host): thin app shell with root coordinator"

# --- 13 ---
git add project.yml
xcodegen generate
git add PulseLedger.xcodeproj/
git commit -m "chore: wire local packages and Lottie in project.yml"

# --- 14 ---
git add PulseLedgerTests/
git commit -m "test: update PulseLedgerTests for package imports"

# --- 15 ---
git add README.md COMMITS.md COMMIT-COMMANDS.sh
git commit -m "docs: add architecture README and commit guides"

# Push when ready:
# git push origin main
