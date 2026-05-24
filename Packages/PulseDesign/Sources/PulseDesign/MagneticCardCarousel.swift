import PulseCore
import SwiftUI

public struct MagneticCardCarousel: View {
    private let accounts: [Account]
    @Binding private var selectedIndex: Int
    @State private var scrollPosition: Int?

    public init(accounts: [Account], selectedIndex: Binding<Int>) {
        self.accounts = accounts
        _selectedIndex = selectedIndex
        _scrollPosition = State(initialValue: selectedIndex.wrappedValue)
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(Array(accounts.enumerated()), id: \.element.id) { index, account in
                    card(for: account, index: index)
                        .containerRelativeFrame(.horizontal, count: 1, spacing: 14)
                        .scaleEffect(scale(for: index))
                        .opacity(opacity(for: index))
                        .animation(.spring(response: 0.38, dampingFraction: 0.82), value: selectedIndex)
                        .id(index)
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollPosition(id: $scrollPosition)
        .frame(height: 220)
        .onChange(of: scrollPosition) { _, newValue in
            guard let newValue, newValue != selectedIndex else { return }
            selectedIndex = newValue
            PulseHaptics.light()
        }
        .onChange(of: selectedIndex) { _, newValue in
            if scrollPosition != newValue {
                scrollPosition = newValue
            }
        }
        .onAppear {
            scrollPosition = selectedIndex
        }
    }

    private func scale(for index: Int) -> CGFloat {
        let distance = abs(index - selectedIndex)
        switch distance {
        case 0: return 1
        case 1: return 0.92
        default: return 0.86
        }
    }

    private func opacity(for index: Int) -> Double {
        let distance = abs(index - selectedIndex)
        switch distance {
        case 0: return 1
        case 1: return 0.75
        default: return 0.55
        }
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
        .shadow(color: .black.opacity(0.25), radius: 12, y: 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(account.name) account, \(account.maskedPan)")
    }
}
