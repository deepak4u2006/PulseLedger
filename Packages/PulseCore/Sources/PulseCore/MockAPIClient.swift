import Combine
import Foundation

/// Simulates network endpoints with random delays and staggered transaction chunks.
public final class MockAPIClient: TransactionAPIService, @unchecked Sendable {
    private let loader: MockDataLoader
    private let delayRange: ClosedRange<TimeInterval>
    private let chunkDelayRange: ClosedRange<TimeInterval>
    private let chunkSize: ClosedRange<Int>

    public init(
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

    public func fetchBalance() async throws -> Money {
        try await simulateNetworkDelay()
        let root = try loader.load()
        guard let account = root.accounts.first.map({ Account(dto: $0) }) else {
            return Money(amount: 0, currencyCode: "EUR")
        }
        let transactions = root.transactions.map(Transaction.init(dto:))
        return FinanceCalculator.balance(account: account, transactions: transactions)
    }

    public func fetchWeeklySpend() async throws -> Money {
        try await simulateNetworkDelay()
        let root = try loader.load()
        let transactions = root.transactions.map(Transaction.init(dto:))
        return FinanceCalculator.weeklySpend(transactions: transactions)
            ?? Money(amount: 0, currencyCode: root.accounts.first?.currencyCode ?? "EUR")
    }

    public func fetchAccounts() async throws -> [Account] {
        try await simulateNetworkDelay()
        let root = try loader.load()
        let pans = ["•••• 4242", "•••• 8810", "•••• 1204"]
        return root.accounts.enumerated().map { index, dto in
            Account(dto: dto, maskedPan: pans[index % pans.count])
        } + [
            Account(id: "acc-travel", name: "Travel", currencyCode: "EUR", openingBalance: 840, maskedPan: "•••• 5519"),
            Account(id: "acc-savings", name: "Savings", currencyCode: "EUR", openingBalance: 12_400, maskedPan: "•••• 0091"),
        ]
    }

    public func streamTransactions(into subject: PassthroughSubject<Transaction, Never>) async throws {
        try await simulateNetworkDelay()
        let root = try loader.load()
        let sorted = root.transactions
            .map(Transaction.init(dto:))
            .sorted { $0.date > $1.date }

        var index = 0
        while index < sorted.count {
            let count = min(Int.random(in: chunkSize), sorted.count - index)
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
