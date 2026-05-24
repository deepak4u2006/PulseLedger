import PulseAuth
import PulseDesign
import PulseSecurity
import PulseTransactions
import SwiftUI
import UIKit

enum AppRoute: Equatable {
    case auth
    case biometricUnlock
    case dashboard
}

@MainActor
final class AppCoordinator: ObservableObject {
    @Published private(set) var route: AppRoute = .auth

    let session: AuthSessionStore
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

    func resetAppState() {
        session.resetAppState()
        route = .auth
    }

    private func resolveInitialRoute() {
        guard session.hasValidSession else {
            session.signOut()
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
                DashboardView(
                    viewModel: DashboardViewModel(),
                    onSignOut: { coordinator.signOut() },
                    onResetAppState: { coordinator.resetAppState() }
                )
            }
        }
        .onShake {
            #if DEBUG
            coordinator.resetAppState()
            #endif
        }
    }
}

// MARK: - DEBUG shake to reset

#if DEBUG
private extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(ShakeDetectorModifier(action: action))
    }
}

private struct ShakeDetectorModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content.background(ShakeDetectorViewRepresentable(onShake: action))
    }
}

private struct ShakeDetectorViewRepresentable: UIViewControllerRepresentable {
    let onShake: () -> Void

    func makeUIViewController(context: Context) -> ShakeDetectorViewController {
        let vc = ShakeDetectorViewController()
        vc.onShake = onShake
        return vc
    }

    func updateUIViewController(_ uiViewController: ShakeDetectorViewController, context: Context) {
        uiViewController.onShake = onShake
    }
}

private final class ShakeDetectorViewController: UIViewController {
    var onShake: (() -> Void)?

    override var canBecomeFirstResponder: Bool { true }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        becomeFirstResponder()
    }

    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            onShake?()
        }
    }
}
#else
private extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self
    }
}
#endif
