import Foundation

struct Money: Hashable, Codable, Sendable {
    var amount: Decimal
    var currencyCode: String

    var formatted: String {
        let n = NSDecimalNumber(decimal: amount)
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = currencyCode
        f.maximumFractionDigits = 2
        return f.string(from: n) ?? "\(amount) \(currencyCode)"
    }
}

enum MoneyMath {
    static func sum(_ items: [Money]) -> Money? {
        guard let first = items.first else { return nil }
        let total = items.dropFirst().reduce(first.amount) { partial, m in
            guard m.currencyCode == first.currencyCode else { return partial }
            return partial + m.amount
        }
        return Money(amount: total, currencyCode: first.currencyCode)
    }
}
