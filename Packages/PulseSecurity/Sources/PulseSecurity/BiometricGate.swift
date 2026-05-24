import Foundation
import LocalAuthentication

public enum BiometricResult: Sendable {
    case success
    case cancelled
    case unavailable
    case failed(String)
}

/// Wraps `LAContext` biometric evaluation for dashboard unlock.
public final class BiometricGate: @unchecked Sendable {
    public init() {}

    public var isBiometricsAvailable: Bool {
        var error: NSError?
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    public func authenticate(reason: String = "Unlock PulseLedger") async -> BiometricResult {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .unavailable
        }
        do {
            let ok = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: reason
            )
            return ok ? .success : .failed("Authentication failed")
        } catch let laError as LAError where laError.code == .userCancel {
            return .cancelled
        } catch {
            return .failed(error.localizedDescription)
        }
    }
}
