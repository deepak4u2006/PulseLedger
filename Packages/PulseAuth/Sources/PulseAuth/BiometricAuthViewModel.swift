import Foundation
import PulseSecurity

@MainActor
public final class BiometricAuthViewModel: ObservableObject {
    private weak var coordinator: AuthCoordinator?
    private let gate = BiometricGate()

    public init(coordinator: AuthCoordinator) {
        self.coordinator = coordinator
    }

    public var enableBiometrics: Bool {
        get { coordinator?.enableBiometrics ?? true }
        set { coordinator?.enableBiometrics = newValue }
    }

    public var canUseBiometrics: Bool { gate.isBiometricsAvailable }

    public func enableAndContinue() async {
        if enableBiometrics, canUseBiometrics {
            _ = await gate.authenticate(reason: "Enable Face ID for PulseLedger")
        }
        coordinator?.confirmBiometrics()
    }

    public func skip() { coordinator?.skipBiometrics() }
}
