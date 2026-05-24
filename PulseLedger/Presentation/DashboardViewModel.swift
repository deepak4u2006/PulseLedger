import Combine
import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var balance = Money(amount: 0, currencyCode: "EUR")
    @Published private(set) var weeklySpend = Money(amount: 0, currencyCode: "EUR")
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var isBalanceLoading = false
    @Published private(set) var isWeeklyLoading = false
    @Published private(set) var isTransactionsLoading = false
    @Published private(set) var isOffline = false

    let reachability: NetworkReachabilitySimulator

    private let api: TransactionAPIService
    private let transactionSubject = PassthroughSubject<Transaction, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var loadTask: Task<Void, Never>?

    init(
        api: TransactionAPIService = MockAPIClient(),
        reachability: NetworkReachabilitySimulator = NetworkReachabilitySimulator()
    ) {
        self.api = api
        self.reachability = reachability
        bindOfflinePipeline()
        bindTransactionStream()
    }

    // MARK: - Combine: offline reachability simulation

    private func bindOfflinePipeline() {
        reachability.isOfflinePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] offline in
                self?.isOffline = offline
            }
            .store(in: &cancellables)
    }

    // MARK: - Combine: staggered transaction stream → list

    private func bindTransactionStream() {
        transactionSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transaction in
                guard let self else { return }
                guard !self.transactions.contains(where: { $0.id == transaction.id }) else { return }
                self.transactions.append(transaction)
            }
            .store(in: &cancellables)
    }

    func toggleOfflineSimulation() {
        reachability.toggleOffline()
    }

    func setOfflineSimulation(_ offline: Bool) {
        reachability.setOffline(offline)
    }

    func refresh() async {
        await load()
    }

    func load() async {
        if isOffline { return }

        loadTask?.cancel()
        transactions = []
        isBalanceLoading = true
        isWeeklyLoading = true
        isTransactionsLoading = true

        loadTask = Task { [weak self] in
            guard let self else { return }
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.fetchBalance() }
                group.addTask { await self.fetchWeeklySpend() }
                group.addTask { await self.fetchTransactionsStaggered() }
            }
        }
        await loadTask?.value
    }

    // MARK: - async/await: simulated API endpoints

    private func fetchBalance() async {
        defer { isBalanceLoading = false }
        guard !Task.isCancelled else { return }
        do {
            balance = try await api.fetchBalance()
        } catch {
            // Keep previous balance on failure
        }
    }

    private func fetchWeeklySpend() async {
        defer { isWeeklyLoading = false }
        guard !Task.isCancelled else { return }
        do {
            weeklySpend = try await api.fetchWeeklySpend()
        } catch {
            // Keep previous weekly spend on failure
        }
    }

    private func fetchTransactionsStaggered() async {
        defer { isTransactionsLoading = false }
        guard !Task.isCancelled else { return }
        do {
            try await api.streamTransactions(into: transactionSubject)
        } catch {
            // Partial list may already be visible
        }
    }
}
