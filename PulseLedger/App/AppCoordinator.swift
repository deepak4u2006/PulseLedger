import PulseAuth
import PulseDesign
import PulseSecurity
import PulseTransactions
import SwiftUI

enum AppRoute: Equatable {
    case auth
    case biometricUnlock
    case dashboard
}

@MainActor
final class AppCoordinator: ObservableObject {
    @Published private(set) var route: AppRoute = .auth

    private let session: AuthSessionStore
    private let biometricGate: BiometricGate

    init(
        session: AuthSessionStore = AuthSessionStore(),
        biometricGate: BiometricGate = BiometricGate()
    ) {
        self.session = session
        self.biometricGate = biometricGate
        resolveInitialRoute()
    }

    func authCoordinator() -> AuthCoordinator {
        AuthCoordinator(session: session) { [weak self] in
            self?.completeAuth()
        }
    }

    func completeAuth() {
        if session.isBiometricsEnabled && biometricGate.isBiometricsAvailable {
            route = .biometricUnlock
        } else {
            route = .dashboard
        }
    }

    func unlockWithBiometrics() async {
        let result = await biometricGate.authenticate()
        switch result {
        case .success, .unavailable:
            route = .dashboard
        case .cancelled, .failed:
            break
        }
    }

    func skipBiometricUnlock() {
        route = .dashboard
    }

    func signOut() {
        session.signOut()
        route = .auth
    }

    private func resolveInitialRoute() {
        guard session.isLoggedIn else {
            route = .auth
            return
        }
        if session.isBiometricsEnabled && biometricGate.isBiometricsAvailable {
            route = .biometricUnlock
        } else {
            route = .dashboard
        }
    }
}

struct RootView: View {
    @StateObject private var coordinator = AppCoordinator()

    var body: some View {
        Group {
            switch coordinator.route {
            case .auth:
                AuthFlowView(coordinator: coordinator.authCoordinator())
            case .biometricUnlock:
                BiometricUnlockView(
                    onUnlock: { await coordinator.unlockWithBiometrics() },
                    onSkip: { coordinator.skipBiometricUnlock() }
                )
            case .dashboard:
                DashboardView(viewModel: DashboardViewModel())
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Sign out") { coordinator.signOut() }
                                .font(.caption)
                                .foregroundStyle(FintechTheme.textSecondary)
                        }
                    }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: coordinator.route)
    }
}
