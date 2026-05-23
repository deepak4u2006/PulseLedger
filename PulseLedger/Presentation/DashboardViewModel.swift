import Foundation
import SwiftData

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var balance = Money(amount: 2847.32, currencyCode: "EUR")
    @Published var transactions: [TransactionRecord] = []
    @Published var isLoading = false

    private let repository: TransactionRepositoryProtocol

    init(repository: TransactionRepositoryProtocol) {
        self.repository = repository
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await repository.seedIfEmpty()
            transactions = try await repository.fetchAll()
        } catch {
            transactions = []
        }
    }
}
