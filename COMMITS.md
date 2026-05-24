# Suggested commit sequence

Apply these in order for a clean review history. **Do not** include `DerivedData/` or `.xcodeproj` noise unless you version the generated project intentionally.

---

### 1. `chore: scaffold local SPM package layout`

**Files**
- `Packages/PulseCore/Package.swift`
- `Packages/PulseDesign/Package.swift`
- `Packages/PulseNetworking/Package.swift`
- `Packages/PulseSecurity/Package.swift`
- `Packages/PulseNotify/Package.swift`
- `Packages/PulseBridge/Package.swift`
- `Packages/PulseAuth/Package.swift`
- `Packages/PulseTransactions/Package.swift`

**Message:** Add empty package manifests for PulseLedger modular architecture.

---

### 2. `feat(core): add PulseCore domain and mock API`

**Files**
- `Packages/PulseCore/Sources/PulseCore/Money.swift`
- `Packages/PulseCore/Sources/PulseCore/Transaction.swift`
- `Packages/PulseCore/Sources/PulseCore/MockDataDTO.swift`
- `Packages/PulseCore/Sources/PulseCore/MockDataLoader.swift`
- `Packages/PulseCore/Sources/PulseCore/FinanceCalculator.swift`
- `Packages/PulseCore/Sources/PulseCore/TransactionAPIService.swift`
- `Packages/PulseCore/Sources/PulseCore/MockAPIClient.swift`
- `Packages/PulseCore/Sources/PulseCore/Resources/mock_data.json`

**Message:** Move money types, finance calculator, and mock JSON loader into PulseCore.

---

### 3. `feat(design): add FintechTheme and skeleton components`

**Files**
- `Packages/PulseDesign/Sources/PulseDesign/FintechTheme.swift`
- `Packages/PulseDesign/Sources/PulseDesign/SkeletonView.swift`
- `Packages/PulseDesign/Sources/PulseDesign/OfflineBanner.swift`

**Message:** Extract shared neobank UI theme and loading skeletons to PulseDesign.

---

### 4. `feat(design): add magnetic card carousel and motion helpers`

**Files**
- `Packages/PulseDesign/Sources/PulseDesign/MagneticCardCarousel.swift`
- `Packages/PulseDesign/Sources/PulseDesign/AnimationHelpers.swift`
- `Packages/PulseDesign/Sources/PulseDesign/Haptics.swift`
- `Packages/PulseDesign/Package.swift` (PulseCore dependency)

**Message:** Add account carousel, balance count-up helper, and haptic feedback utilities.

---

### 5. `feat(networking): add NWPathMonitor reachability`

**Files**
- `Packages/PulseNetworking/Sources/PulseNetworking/NetworkReachabilityMonitor.swift`
- `Packages/PulseNetworking/Sources/PulseNetworking/OfflineBannerModifier.swift`

**Message:** Replace offline simulation with real Network framework path monitoring.

---

### 6. `feat(security): add Keychain session and biometric gate`

**Files**
- `Packages/PulseSecurity/Sources/PulseSecurity/KeychainStore.swift`
- `Packages/PulseSecurity/Sources/PulseSecurity/AuthSessionStore.swift`
- `Packages/PulseSecurity/Sources/PulseSecurity/BiometricGate.swift`
- `Packages/PulseSecurity/Sources/PulseSecurity/SecureEnclaveStub.swift`
- `Packages/PulseSecurity/README.md`

**Message:** Port VaultFlow-style Keychain storage and LAContext unlock wrapper.

---

### 7. `feat(notify): add payment notification center`

**Files**
- `Packages/PulseNotify/Sources/PulseNotify/PaymentNotificationCenter.swift`

**Message:** Port NotifyLab-style local notifications for payment received events.

---

### 8. `feat(bridge): add UIKit category spend bar chart`

**Files**
- `Packages/PulseBridge/Sources/PulseBridge/CategoryBarChartView.swift`
- `Packages/PulseBridge/Sources/PulseBridge/CategoryBarChartBridge.swift`

**Message:** Bridge UIKit bar chart for dashboard category breakdown.

---

### 9. `feat(auth): add MVVM-C auth flow with Lottie success`

**Files**
- `Packages/PulseAuth/Sources/PulseAuth/*`
- `Packages/PulseAuth/Sources/PulseAuth/Resources/success.json`
- `Packages/PulseAuth/Package.swift` (lottie-ios dependency)

**Message:** Implement welcome → email → PIN → biometrics coordinator flow with success animation.

---

### 10. `feat(transactions): add dashboard MVVM with staggered API`

**Files**
- `Packages/PulseTransactions/Sources/PulseTransactions/DashboardViewModel.swift`
- `Packages/PulseTransactions/Sources/PulseTransactions/DashboardView.swift`

**Message:** Migrate dashboard to package with reachability, notifications, carousel, and chart.

---

### 11. `feat(transactions): add transaction detail VIP module`

**Files**
- `Packages/PulseTransactions/Sources/PulseTransactions/TransactionDetailVIP.swift`

**Message:** Add VIP interactor, presenter, router, and detail view for transaction rows.

---

### 12. `refactor(host): thin app shell with root coordinator`

**Files**
- `PulseLedger/PulseLedgerApp.swift`
- `PulseLedger/App/AppCoordinator.swift`
- `PulseLedger/App/BiometricUnlockView.swift`
- Remove migrated files under `PulseLedger/Data`, `Domain`, `Presentation`, `Services`, `Money.swift`, `FintechTheme.swift`

**Message:** Route auth, biometric unlock, and dashboard from a thin host coordinator.

---

### 13. `chore: wire local packages and Lottie in project.yml`

**Files**
- `project.yml`
- Regenerated `PulseLedger.xcodeproj`

**Message:** Configure XcodeGen for all Pulse packages and Face ID usage description.

---

### 14. `test: update PulseLedgerTests for package imports`

**Files**
- `PulseLedgerTests/PulseLedgerTests.swift`

**Message:** Point unit tests at PulseCore and PulseSecurity with category spend and keychain coverage.

---

### 15. `docs: add architecture README and commit guide`

**Files**
- `README.md`
- `COMMITS.md`

**Message:** Document package map, patterns table, user journey, and suggested commit order.

---

## Optional follow-ups (not in this PR)

- Fix `.github/workflows` for SPM + Lottie cache
- Remove duplicate `PulseLedger/Resources/mock_data.json` if only PulseCore bundle is needed
- Add PulseDesign preview assets
