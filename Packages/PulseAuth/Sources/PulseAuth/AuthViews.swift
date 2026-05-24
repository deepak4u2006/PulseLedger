import Lottie
import PulseDesign
import PulseSecurity
import SwiftUI

public struct AuthFlowView: View {
    @ObservedObject private var coordinator: AuthCoordinator

    public init(coordinator: AuthCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        NavigationStack {
            Group {
                switch coordinator.step {
                case .welcome:
                    WelcomeAuthView(coordinator: coordinator)
                case .email(let isSignup):
                    EmailAuthView(coordinator: coordinator, isSignup: isSignup)
                case .pin:
                    PINAuthView(coordinator: coordinator)
                case .biometrics:
                    BiometricAuthView(coordinator: coordinator)
                case .success:
                    AuthSuccessView {
                        coordinator.completeSuccessAnimation()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FintechTheme.background)
        }
        .preferredColorScheme(.dark)
    }
}

struct WelcomeAuthView: View {
    @ObservedObject var coordinator: AuthCoordinator

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: 56))
                .foregroundStyle(FintechTheme.accent)
            Text("PulseLedger")
                .font(.largeTitle.bold())
                .foregroundStyle(FintechTheme.textPrimary)
            Text("Your neobank demo — patterns in one app")
                .multilineTextAlignment(.center)
                .foregroundStyle(FintechTheme.textSecondary)
            Spacer()
            Button("Log in") { coordinator.startLogin() }
                .buttonStyle(FintechPrimaryButtonStyle())
            Button("Sign up") { coordinator.startSignup() }
                .foregroundStyle(FintechTheme.accent)
        }
        .padding(24)
        .navigationBarHidden(true)
    }
}

struct EmailAuthView: View {
    @ObservedObject var coordinator: AuthCoordinator
    let isSignup: Bool
    @FocusState private var emailFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(isSignup ? "Create account" : "Welcome back")
                .font(.title.bold())
                .foregroundStyle(FintechTheme.textPrimary)
            TextField("Email", text: $coordinator.emailDraft)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocorrectionDisabled()
                .focused($emailFocused)
                .padding()
                .background(FintechTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            if let error = coordinator.errorMessage {
                Text(error).font(.caption).foregroundStyle(FintechTheme.danger)
            }
            Button("Continue") { coordinator.submitEmail() }
                .buttonStyle(FintechPrimaryButtonStyle())
            Spacer()
        }
        .padding(24)
        .navigationTitle(isSignup ? "Sign up" : "Log in")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { emailFocused = true }
    }
}

struct PINAuthView: View {
    @ObservedObject var coordinator: AuthCoordinator
    private let digits = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", "⌫"]

    var body: some View {
        VStack(spacing: 24) {
            Text("Set your PIN")
                .font(.title2.bold())
                .foregroundStyle(FintechTheme.textPrimary)
            HStack(spacing: 12) {
                ForEach(0 ..< 6, id: \.self) { index in
                    Circle()
                        .fill(index < coordinator.pinDraft.count ? FintechTheme.accent : FintechTheme.surface)
                        .frame(width: 14, height: 14)
                }
            }
            if let error = coordinator.errorMessage {
                Text(error).font(.caption).foregroundStyle(FintechTheme.danger)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(digits, id: \.self) { digit in
                    if digit.isEmpty {
                        Color.clear.frame(height: 52)
                    } else {
                        Button {
                            if digit == "⌫" {
                                coordinator.deletePinDigit()
                            } else {
                                coordinator.appendPinDigit(digit)
                            }
                        } label: {
                            Text(digit)
                                .font(.title2)
                                .frame(maxWidth: .infinity, minHeight: 52)
                                .background(FintechTheme.surface)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(FintechTheme.textPrimary)
                    }
                }
            }
            Button("Continue") { coordinator.submitPIN() }
                .buttonStyle(FintechPrimaryButtonStyle())
        }
        .padding(24)
        .navigationTitle("PIN")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct BiometricAuthView: View {
    @ObservedObject var coordinator: AuthCoordinator
    private let gate = BiometricGate()

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "faceid")
                .font(.system(size: 48))
                .foregroundStyle(FintechTheme.accent)
            Text("Enable Face ID?")
                .font(.title2.bold())
                .foregroundStyle(FintechTheme.textPrimary)
            if gate.isBiometricsAvailable {
                Toggle("Use biometrics to unlock", isOn: $coordinator.enableBiometrics)
                    .tint(FintechTheme.accent)
            } else {
                Text("Biometrics unavailable on this device")
                    .font(.caption)
                    .foregroundStyle(FintechTheme.textSecondary)
            }
            Button("Continue") {
                Task { @MainActor in
                    if coordinator.enableBiometrics, gate.isBiometricsAvailable {
                        _ = await gate.authenticate(reason: "Enable Face ID for PulseLedger")
                    }
                    coordinator.confirmBiometrics()
                }
            }
            .buttonStyle(FintechPrimaryButtonStyle())
            Button("Not now") { coordinator.skipBiometrics() }
                .foregroundStyle(FintechTheme.textSecondary)
        }
        .padding(24)
        .navigationTitle("Biometrics")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AuthSuccessView: View {
    let onFinish: () -> Void
    @State private var didFinish = false

    var body: some View {
        VStack(spacing: 20) {
            if let animation = LottieAnimation.named("success", bundle: .module) {
                LottieView(animation: animation)
                    .playing(loopMode: .playOnce)
                    .animationSpeed(1.2)
                    .frame(width: 160, height: 160)
                    .allowsHitTesting(false)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(FintechTheme.accent)
            }
            Text("You're in")
                .font(.title.bold())
                .foregroundStyle(FintechTheme.textPrimary)
            Text("Tap to continue")
                .font(.caption)
                .foregroundStyle(FintechTheme.textSecondary)
        }
        .contentShape(Rectangle())
        .onTapGesture { finishOnce() }
        .task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            finishOnce()
        }
        .navigationBarHidden(true)
    }

    private func finishOnce() {
        guard !didFinish else { return }
        didFinish = true
        onFinish()
    }
}
