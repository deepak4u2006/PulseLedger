import XCTest
@testable import PulseLedger

final class PulseLedgerTests: XCTestCase {
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
}
