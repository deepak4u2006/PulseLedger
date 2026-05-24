import Foundation

public struct Money: Hashable, Codable, Sendable {
    public var amount: Decimal
    public var currencyCode: String

    public init(amount: Decimal, currencyCode: String) {
        self.amount = amount
        self.currencyCode = currencyCode
    }

    public var formatted: String {
        let n = NSDecimalNumber(decimal: amount)
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = currencyCode
        f.maximumFractionDigits = 2
        return f.string(from: n) ?? "\(amount) \(currencyCode)"
    }
}

public enum MoneyMath {
    public static func sum(_ items: [Money]) -> Money? {
        guard let first = items.first else { return nil }
        let total = items.dropFirst().reduce(first.amount) { partial, m in
            guard m.currencyCode == first.currencyCode else { return partial }
            return partial + m.amount
        }
        return Money(amount: total, currencyCode: first.currencyCode)
    }
}
