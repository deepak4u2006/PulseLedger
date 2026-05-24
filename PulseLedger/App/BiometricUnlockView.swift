import PulseDesign
import SwiftUI

struct BiometricUnlockView: View {
    let onUnlock: () async -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "faceid")
                .font(.system(size: 56))
                .foregroundStyle(FintechTheme.accent)
            Text("Unlock PulseLedger")
                .font(.title2.bold())
                .foregroundStyle(FintechTheme.textPrimary)
            Text("Use Face ID to open your dashboard")
                .foregroundStyle(FintechTheme.textSecondary)
            Button("Unlock") {
                Task { await onUnlock() }
            }
            .buttonStyle(FintechPrimaryButtonStyle())
            .padding(.horizontal, 24)
            Button("Use PIN later", action: onSkip)
                .foregroundStyle(FintechTheme.textSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(FintechTheme.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}
