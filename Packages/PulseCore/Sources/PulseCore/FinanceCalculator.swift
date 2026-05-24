import Foundation

public enum FinanceCalculator {
    /// Balance = opening balance + credits − debits (same currency).
    public static func balance(account: Account, transactions: [Transaction]) -> Money {
        var amount = account.openingBalance
        for tx in transactions where tx.currencyCode == account.currencyCode {
            if tx.isDebit {
                amount -= tx.amount
            } else {
                amount += tx.amount
            }
        }
        return Money(amount: amount, currencyCode: account.currencyCode)
    }

    /// Sum of debit amounts in the last 7 days (inclusive of today).
    public static func weeklySpend(
        transactions: [Transaction],
        now: Date = .now,
        calendar: Calendar = .current
    ) -> Money? {
        guard let weekStart = calendar.date(byAdding: .day, value: -7, to: now) else {
            return nil
        }
        let debits = transactions.filter { tx in
            tx.isDebit && tx.date >= weekStart && tx.date <= now
        }
        guard let first = debits.first else { return nil }
        let items = debits.map { Money(amount: $0.amount, currencyCode: $0.currencyCode) }
        return MoneyMath.sum(items) ?? Money(amount: 0, currencyCode: first.currencyCode)
    }

    /// Debit totals grouped by category for chart display.
    public static func categorySpend(transactions: [Transaction], limit: Int = 5) -> [CategorySpend] {
        var totals: [String: Decimal] = [:]
        for tx in transactions where tx.isDebit {
            totals[tx.category, default: 0] += tx.amount
        }
        return totals
            .map { CategorySpend(category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
            .prefix(limit)
            .map { $0 }
    }
}
