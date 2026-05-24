import PulseCore
import SwiftUI

public struct MagneticCardCarousel: View {
    private let accounts: [Account]
    @Binding private var selectedIndex: Int
    @State private var dragScale: CGFloat = 1

    public init(accounts: [Account], selectedIndex: Binding<Int>) {
        self.accounts = accounts
        _selectedIndex = selectedIndex
    }

    public var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(Array(accounts.enumerated()), id: \.element.id) { index, account in
                card(for: account, index: index)
                    .tag(index)
                    .pulseCardScale(active: selectedIndex == index && dragScale < 1)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: accounts.count > 1 ? .always : .never))
        .frame(height: 220)
        .onChange(of: selectedIndex) { _, _ in
            PulseHaptics.selection()
        }
        .simultaneousGesture(
            DragGesture(minimumDistance: 8)
                .onChanged { _ in dragScale = 0.96 }
                .onEnded { _ in dragScale = 1 }
        )
    }

    private func card(for account: Account, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(account.name.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.75))
            Text(account.maskedPan)
                .font(.title2.bold())
            Spacer(minLength: 0)
            Text("PULSE MEMBER")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.white.opacity(0.6))
        }
        .foregroundStyle(.white)
        .padding(24)
        .frame(maxWidth: .infinity, minHeight: 180, alignment: .leading)
        .background(FintechTheme.cardGradient(index: index))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 4)
        .shadow(color: .black.opacity(0.25), radius: 12, y: 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(account.name) account, \(account.maskedPan)")
    }
}
