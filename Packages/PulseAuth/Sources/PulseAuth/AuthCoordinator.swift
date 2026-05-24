import Foundation
import PulseDesign
import PulseSecurity

@MainActor
public final class AuthCoordinator: ObservableObject {
    @Published public private(set) var step: AuthFlowStep = .welcome
    @Published public var emailDraft = ""
    @Published public var pinDraft = ""
    @Published public var enableBiometrics = true
    @Published public var errorMessage: String?

    private let session: AuthSessionStore
    private let onComplete: () -> Void
    private var isSignupFlow = false

    public init(session: AuthSessionStore = AuthSessionStore(), onComplete: @escaping () -> Void) {
        self.session = session
        self.onComplete = onComplete
    }

    public func showWelcome() { step = .welcome }

    public func startLogin() {
        isSignupFlow = false
        emailDraft = session.email ?? ""
        step = .email(isSignup: false)
        PulseHaptics.light()
    }

    public func startSignup() {
        isSignupFlow = true
        emailDraft = ""
        step = .email(isSignup: true)
        PulseHaptics.light()
    }

    public func submitEmail() {
        let trimmed = emailDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.contains("@"), trimmed.count >= 5 else {
            errorMessage = "Enter a valid email"
            return
        }
        errorMessage = nil
        session.email = trimmed
        pinDraft = ""
        step = .pin
        PulseHaptics.medium()
    }

    public func appendPinDigit(_ digit: String) {
        guard pinDraft.count < 6, digit.count == 1, digit.allSatisfy(\.isNumber) else { return }
        pinDraft.append(digit)
        PulseHaptics.selection()
        if pinDraft.count >= 4 {
            session.pin = pinDraft
        }
    }

    public func deletePinDigit() {
        guard !pinDraft.isEmpty else { return }
        pinDraft.removeLast()
        PulseHaptics.light()
    }

    public func submitPIN() {
        guard pinDraft.count >= 4 else {
            errorMessage = "PIN must be 4–6 digits"
            return
        }
        errorMessage = nil
        session.pin = pinDraft
        step = .biometrics
        PulseHaptics.medium()
    }

    public func skipBiometrics() {
        session.isBiometricsEnabled = false
        finishAuth()
    }

    public func confirmBiometrics() {
        session.isBiometricsEnabled = enableBiometrics
        finishAuth()
    }

    private func finishAuth() {
        session.isLoggedIn = true
        step = .success
        PulseHaptics.success()
        Task {
            try? await Task.sleep(nanoseconds: 1_800_000_000)
            onComplete()
        }
    }
}
