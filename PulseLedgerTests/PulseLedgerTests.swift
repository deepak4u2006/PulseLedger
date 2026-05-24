import Combine
import XCTest
@testable import PulseLedger

final class PulseLedgerTests: XCTestCase {
    private var mockBundle: Bundle {
        Bundle(for: MockDataLoader.self)
    }
    // MARK: - Money

    func testMoneyFormattedUsesCurrencyCode() {
        let money = Money(amount: 42.5, currencyCode: "EUR")
        XCTAssertTrue(money.formatted.contains("42"))
        XCTAssertTrue(money.formatted.contains("€") || money.formatted.contains("EUR"))
    }

    func testMoneyMathSumSameCurrency() {
        let items = [
            Money(amount: 10, currencyCode: "EUR"),
            Money(amount: 5.5, currencyCode: "EUR"),
            Money(amount: 2.5, currencyCode: "EUR"),
        ]
        let total = MoneyMath.sum(items)
        XCTAssertEqual(total?.amount, 18)
        XCTAssertEqual(total?.currencyCode, "EUR")
    }

    func testMoneyMathSumIgnoresMixedCurrency() {
        let items = [
            Money(amount: 10, currencyCode: "EUR"),
            Money(amount: 5, currencyCode: "USD"),
        ]
        let total = MoneyMath.sum(items)
        XCTAssertEqual(total?.amount, 10)
        XCTAssertEqual(total?.currencyCode, "EUR")
    }

    func testMoneyMathSumEmptyReturnsNil() {
        XCTAssertNil(MoneyMath.sum([]))
    }

    // MARK: - Mock data loader

    func testMockDataLoaderLoadsBundleJSON() throws {
        let loader = MockDataLoader(bundle: mockBundle)
        let root = try loader.load()
        XCTAssertFalse(root.accounts.isEmpty)
        XCTAssertFalse(root.categories.isEmpty)
        XCTAssertGreaterThanOrEqual(root.transactions.count, 8)
    }

    // MARK: - Finance calculator

    func testBalanceComputedFromOpeningAndTransactions() {
        let account = Account(
            id: "a1",
            name: "Test",
            currencyCode: "EUR",
            openingBalance: 1000
        )
        let transactions = [
            Transaction(
                id: "1", title: "Pay", amount: 100, currencyCode: "EUR",
                category: "Income", date: .now, isDebit: false
            ),
            Transaction(
                id: "2", title: "Shop", amount: 50, currencyCode: "EUR",
                category: "Food", date: .now, isDebit: true
            ),
        ]
        let balance = FinanceCalculator.balance(account: account, transactions: transactions)
        XCTAssertEqual(balance.amount, 1050)
        XCTAssertEqual(balance.currencyCode, "EUR")
    }

    func testWeeklySpendSumsDebitsInLastSevenDays() {
        let calendar = Calendar(identifier: .gregorian)
        let now = calendar.date(from: DateComponents(year: 2026, month: 5, day: 24))!
        let recent = calendar.date(byAdding: .day, value: -2, to: now)!
        let old = calendar.date(byAdding: .day, value: -10, to: now)!

        let transactions = [
            Transaction(
                id: "1", title: "Coffee", amount: 10, currencyCode: "EUR",
                category: "Food", date: recent, isDebit: true
            ),
            Transaction(
                id: "2", title: "Rent", amount: 999, currencyCode: "EUR",
                category: "Bills", date: old, isDebit: true
            ),
            Transaction(
                id: "3", title: "Salary", amount: 100, currencyCode: "EUR",
                category: "Income", date: recent, isDebit: false
            ),
        ]

        let spend = FinanceCalculator.weeklySpend(transactions: transactions, now: now, calendar: calendar)
        XCTAssertEqual(spend?.amount, 10)
    }

    // MARK: - Mock API + Combine stream

    func testMockAPIClientStreamsTransactionsIncrementally() async throws {
        let loader = MockDataLoader(bundle: mockBundle)
        let client = MockAPIClient(
            loader: loader,
            delayRange: 0 ... 0,
            chunkDelayRange: 0 ... 0,
            chunkSize: 1 ... 1
        )

        let subject = PassthroughSubject<Transaction, Never>()
        var received: [Transaction] = []
        let cancellable = subject.sink { received.append($0) }

        try await client.streamTransactions(into: subject)
        cancellable.cancel()

        XCTAssertEqual(received.count, 10)
        XCTAssertEqual(Set(received.map(\.id)).count, 10)
    }

    func testMockAPIClientFetchBalanceMatchesCalculator() async throws {
        let loader = MockDataLoader(bundle: mockBundle)
        let client = MockAPIClient(loader: loader, delayRange: 0 ... 0, chunkDelayRange: 0 ... 0)
        let balance = try await client.fetchBalance()
        let root = try loader.load()
        let account = Account(dto: root.accounts[0])
        let txs = root.transactions.map(Transaction.init(dto:))
        let expected = FinanceCalculator.balance(account: account, transactions: txs)
        XCTAssertEqual(balance.amount, expected.amount)
        XCTAssertEqual(balance.currencyCode, expected.currencyCode)
    }
}
