import Combine
import Foundation

/// Simulates network endpoints with random 1–2s delays and staggered transaction chunks.
final class MockAPIClient: TransactionAPIService, @unchecked Sendable {
    private let loader: MockDataLoader
    private let delayRange: ClosedRange<TimeInterval>
    private let chunkDelayRange: ClosedRange<TimeInterval>
    private let chunkSize: ClosedRange<Int>

    init(
        loader: MockDataLoader = MockDataLoader(),
        delayRange: ClosedRange<TimeInterval> = 1.0 ... 2.0,
        chunkDelayRange: ClosedRange<TimeInterval> = 0.3 ... 0.5,
        chunkSize: ClosedRange<Int> = 1 ... 2
    ) {
        self.loader = loader
        self.delayRange = delayRange
        self.chunkDelayRange = chunkDelayRange
        self.chunkSize = chunkSize
    }

    func fetchBalance() async throws -> Money {
        try await simulateNetworkDelay()
        let root = try loader.load()
        guard let account = root.accounts.first.map(Account.init(dto:)) else {
            return Money(amount: 0, currencyCode: "EUR")
        }
        let transactions = root.transactions.map(Transaction.init(dto:))
        return FinanceCalculator.balance(account: account, transactions: transactions)
    }

    func fetchWeeklySpend() async throws -> Money {
        try await simulateNetworkDelay()
        let root = try loader.load()
        let transactions = root.transactions.map(Transaction.init(dto:))
        return FinanceCalculator.weeklySpend(transactions: transactions)
            ?? Money(amount: 0, currencyCode: root.accounts.first?.currencyCode ?? "EUR")
    }

    func streamTransactions(into subject: PassthroughSubject<Transaction, Never>) async throws {
        try await simulateNetworkDelay()
        let root = try loader.load()
        let sorted = root.transactions
            .map(Transaction.init(dto:))
            .sorted { $0.date > $1.date }

        var index = 0
        while index < sorted.count {
            let count = min(
                Int.random(in: chunkSize),
                sorted.count - index
            )
            let chunk = Array(sorted[index ..< (index + count)])
            index += count

            let chunkSeconds = Double.random(in: chunkDelayRange)
            try await Task.sleep(nanoseconds: UInt64(chunkSeconds * 1_000_000_000))
            for tx in chunk {
                subject.send(tx)
            }
        }
    }

    private func simulateNetworkDelay() async throws {
        let seconds = Double.random(in: delayRange)
        try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        try Task.checkCancellation()
    }
}
