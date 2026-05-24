import PulseCore
import SwiftUI

public struct AnimatedBalanceText: View {
    private let money: Money
    private let font: Font

    @State private var displayedAmount: Decimal = 0
    @State private var animateTask: Task<Void, Never>?

    public init(money: Money, font: Font = .system(size: 36, weight: .bold, design: .rounded)) {
        self.money = money
        self.font = font
    }

    public var body: some View {
        Text(formatted(displayedAmount, currencyCode: money.currencyCode))
            .font(font)
            .foregroundStyle(FintechTheme.textPrimary)
            .contentTransition(.numericText())
            .animation(.easeOut(duration: 0.35), value: displayedAmount)
            .onChange(of: money.amount) { _, newValue in
                animate(from: displayedAmount, to: newValue)
            }
            .onAppear {
                if displayedAmount == 0, money.amount != 0 {
                    animate(from: 0, to: money.amount)
                } else {
                    displayedAmount = money.amount
                }
            }
            .onDisappear {
                animateTask?.cancel()
            }
    }

    private func animate(from start: Decimal, to end: Decimal) {
        animateTask?.cancel()
        let startDouble = NSDecimalNumber(decimal: start).doubleValue
        let endDouble = NSDecimalNumber(decimal: end).doubleValue
        guard abs(endDouble - startDouble) > 0.001 else {
            displayedAmount = end
            return
        }

        animateTask = Task { @MainActor in
            let steps = 24
            let stepDuration = 0.8 / Double(steps)
            for step in 1 ... steps {
                guard !Task.isCancelled else { return }
                let progress = Double(step) / Double(steps)
                let eased = 1 - pow(1 - progress, 3)
                let value = startDouble + (endDouble - startDouble) * eased
                displayedAmount = Decimal(value)
                try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
            }
            displayedAmount = end
        }
    }

    private func formatted(_ amount: Decimal, currencyCode: String) -> String {
        Money(amount: amount, currencyCode: currencyCode).formatted
    }
}

public extension View {
    func pulseCardScale(active: Bool) -> some View {
        scaleEffect(active ? 0.96 : 1)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: active)
    }
}
