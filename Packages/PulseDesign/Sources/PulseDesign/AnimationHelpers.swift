import PulseCore
import SwiftUI

public struct AnimatedBalanceText: View {
    private let money: Money
    private let font: Font

    public init(money: Money, font: Font = .system(size: 36, weight: .bold, design: .rounded)) {
        self.money = money
        self.font = font
    }

    public var body: some View {
        Text(money.formatted)
            .font(font)
            .foregroundStyle(FintechTheme.textPrimary)
            .contentTransition(.numericText(value: NSDecimalNumber(decimal: money.amount).doubleValue))
            .animation(.spring(response: 0.55, dampingFraction: 0.82), value: money.amount)
    }
}

public extension View {
    func pulseCardScale(active: Bool) -> some View {
        scaleEffect(active ? 0.96 : 1)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: active)
    }
}
