import Lottie
import PulseDesign
import SwiftUI

public struct AuthFlowView: View {
    @ObservedObject private var coordinator: AuthCoordinator

    public init(coordinator: AuthCoordinator) {
        self.coordinator = coordinator
    }

    public var body: some View {
        ZStack {
            FintechTheme.background.ignoresSafeArea()
            switch coordinator.step {
            case .welcome:
                WelcomeAuthView(viewModel: WelcomeViewModel(coordinator: coordinator))
            case .email(let isSignup):
                EmailAuthView(viewModel: EmailAuthViewModel(isSignup: isSignup, coordinator: coordinator))
            case .pin:
                PINAuthView(viewModel: PINAuthViewModel(coordinator: coordinator))
            case .biometrics:
                BiometricAuthView(viewModel: BiometricAuthViewModel(coordinator: coordinator))
            case .success:
                AuthSuccessView()
            }
        }
        .preferredColorScheme(.dark)
        .animation(.spring(response: 0.45, dampingFraction: 0.86), value: coordinator.step)
    }
}

struct WelcomeAuthView: View {
    @ObservedObject var viewModel: WelcomeViewModel

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
            Button("Log in") { viewModel.loginTapped() }
                .buttonStyle(FintechPrimaryButtonStyle())
            Button("Sign up") { viewModel.signupTapped() }
                .foregroundStyle(FintechTheme.accent)
        }
        .padding(24)
    }
}

struct EmailAuthView: View {
    @ObservedObject var viewModel: EmailAuthViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(viewModel.isSignup ? "Create account" : "Welcome back")
                .font(.title.bold())
                .foregroundStyle(FintechTheme.textPrimary)
            TextField("Email", text: Binding(
                get: { viewModel.email },
                set: { viewModel.email = $0 }
            ))
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            .padding()
            .background(FintechTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            if let error = viewModel.errorMessage {
                Text(error).font(.caption).foregroundStyle(FintechTheme.danger)
            }
            Button("Continue") { viewModel.continueTapped() }
                .buttonStyle(FintechPrimaryButtonStyle())
            Spacer()
        }
        .padding(24)
    }
}

struct PINAuthView: View {
    @ObservedObject var viewModel: PINAuthViewModel
    private let digits = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", "⌫"]

    var body: some View {
        VStack(spacing: 24) {
            Text("Set your PIN")
                .font(.title2.bold())
                .foregroundStyle(FintechTheme.textPrimary)
            HStack(spacing: 12) {
                ForEach(0 ..< 6, id: \.self) { index in
                    Circle()
                        .fill(index < viewModel.pin.count ? FintechTheme.accent : FintechTheme.surface)
                        .frame(width: 14, height: 14)
                }
            }
            if let error = viewModel.errorMessage {
                Text(error).font(.caption).foregroundStyle(FintechTheme.danger)
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(digits, id: \.self) { digit in
                    if digit.isEmpty {
                        Color.clear.frame(height: 52)
                    } else {
                        Button {
                            if digit == "⌫" { viewModel.delete() } else { viewModel.digit(digit) }
                        } label: {
                            Text(digit)
                                .font(.title2)
                                .frame(maxWidth: .infinity, minHeight: 52)
                                .background(FintechTheme.surface)
                                .clipShape(Circle())
                        }
                        .foregroundStyle(FintechTheme.textPrimary)
                    }
                }
            }
            Button("Continue") { viewModel.continueTapped() }
                .buttonStyle(FintechPrimaryButtonStyle())
        }
        .padding(24)
    }
}

struct BiometricAuthView: View {
    @ObservedObject var viewModel: BiometricAuthViewModel

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "faceid")
                .font(.system(size: 48))
                .foregroundStyle(FintechTheme.accent)
            Text("Enable Face ID?")
                .font(.title2.bold())
                .foregroundStyle(FintechTheme.textPrimary)
            if viewModel.canUseBiometrics {
                Toggle("Use biometrics to unlock", isOn: Binding(
                    get: { viewModel.enableBiometrics },
                    set: { viewModel.enableBiometrics = $0 }
                ))
                .tint(FintechTheme.accent)
            } else {
                Text("Biometrics unavailable on this device")
                    .font(.caption)
                    .foregroundStyle(FintechTheme.textSecondary)
            }
            Button("Continue") {
                Task { await viewModel.enableAndContinue() }
            }
            .buttonStyle(FintechPrimaryButtonStyle())
            Button("Not now") { viewModel.skip() }
                .foregroundStyle(FintechTheme.textSecondary)
        }
        .padding(24)
    }
}

struct AuthSuccessView: View {
    var body: some View {
        VStack(spacing: 20) {
            if let animation = LottieAnimation.named("success", bundle: .module) {
                LottieView(animation: animation)
                    .playing(loopMode: .playOnce)
                    .frame(width: 160, height: 160)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(FintechTheme.accent)
            }
            Text("You're in")
                .font(.title.bold())
                .foregroundStyle(FintechTheme.textPrimary)
        }
    }
}
