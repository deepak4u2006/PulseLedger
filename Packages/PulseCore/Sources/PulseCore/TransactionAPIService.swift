import Combine
import Foundation

public protocol TransactionAPIService: Sendable {
    func fetchBalance() async throws -> Money
    func fetchWeeklySpend() async throws -> Money
    func fetchAccounts() async throws -> [Account]
    func streamTransactions(into subject: PassthroughSubject<Transaction, Never>) async throws
}

public protocol TransactionStreamDelegate: AnyObject, Sendable {
    func didReceiveCreditTransaction(_ transaction: Transaction) async
}
