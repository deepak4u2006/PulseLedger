import Foundation
import SwiftData

protocol TransactionRepositoryProtocol: Sendable {
    func fetchAll() async throws -> [TransactionRecord]
    func seedIfEmpty() async throws
}

actor TransactionRepository: TransactionRepositoryProtocol {
    private let context: ModelContext

    init(context: ModelContext) { self.context = context }

    func fetchAll() async throws -> [TransactionRecord] {
        let d = FetchDescriptor<TransactionRecord>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        return try context.fetch(d)
    }

    func seedIfEmpty() async throws {
        let existing = try await fetchAll()
        guard existing.isEmpty else { return }
        let samples = [
            TransactionRecord(title: "Coffee Lab", amount: 4.50, category: "Food", isDebit: true),
            TransactionRecord(title: "Salary", amount: 3200, category: "Income", isDebit: false),
            TransactionRecord(title: "Metro", amount: 2.40, category: "Transport", isDebit: true),
            TransactionRecord(title: "Transfer to Savings", amount: 500, category: "Savings", isDebit: true),
        ]
        samples.forEach { context.insert($0) }
        try context.save()
    }
}
