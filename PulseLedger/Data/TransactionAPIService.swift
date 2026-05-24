import Combine
import Foundation

protocol TransactionAPIService: Sendable {
    func fetchBalance() async throws -> Money
    func fetchWeeklySpend() async throws -> Money
    /// Streams transactions incrementally via Combine; completes when all rows emitted.
    func streamTransactions(into subject: PassthroughSubject<Transaction, Never>) async throws
}
