import Combine
import Foundation
import PulseCore
import PulseNetworking
import PulseNotify

@MainActor
public final class DashboardViewModel: ObservableObject {
    @Published public private(set) var balance = Money(amount: 0, currencyCode: "EUR")
    @Published public private(set) var weeklySpend = Money(amount: 0, currencyCode: "EUR")
    @Published public private(set) var transactions: [Transaction] = []
    @Published public private(set) var accounts: [Account] = []
    @Published public private(set) var categorySpend: [CategorySpend] = []
    @Published public private(set) var isBalanceLoading = false
    @Published public private(set) var isWeeklyLoading = false
    @Published public private(set) var isTransactionsLoading = false
    @Published public private(set) var isChartLoading = false
    @Published public private(set) var isOffline = false
    @Published public var selectedCardIndex = 0
    @Published public var showNotificationPrompt = false

    public let reachability: NetworkReachabilityMonitor
    public let notifications: PaymentNotificationCenter

    private let api: TransactionAPIService
    private let transactionSubject = PassthroughSubject<Transaction, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var loadTask: Task<Void, Never>?
    private var notifiedCreditIDs = Set<String>()
    private var isInitialStreamLoad = false

    public init(
        api: TransactionAPIService = MockAPIClient(),
        reachability: NetworkReachabilityMonitor = NetworkReachabilityMonitor(),
        notifications: PaymentNotificationCenter? = nil
    ) {
        self.api = api
        self.reachability = reachability
        self.notifications = notifications ?? PaymentNotificationCenter()
        bindOfflinePipeline()
        bindTransactionStream()
    }

    private func bindOfflinePipeline() {
        reachability.isOfflinePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] offline in
                self?.isOffline = offline
            }
            .store(in: &cancellables)
    }

    private func bindTransactionStream() {
        transactionSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transaction in
                guard let self else { return }
                guard !self.transactions.contains(where: { $0.id == transaction.id }) else { return }
                self.transactions.append(transaction)
                if !self.isInitialStreamLoad {
                    self.refreshCategorySpend()
                }
                if !transaction.isDebit {
                    Task { await self.handleCredit(transaction) }
                }
            }
            .store(in: &cancellables)
    }

    private func handleCredit(_ transaction: Transaction) async {
        guard !notifiedCreditIDs.contains(transaction.id) else { return }
        notifiedCreditIDs.insert(transaction.id)

        if notifications.authorizationStatus == .notDetermined {
            showNotificationPrompt = true
        }

        let money = Money(amount: transaction.amount, currencyCode: transaction.currencyCode)
        await notifications.schedulePaymentReceived(title: transaction.title, amount: money.formatted)
    }

    public func confirmNotificationPermission() async {
        showNotificationPrompt = false
        _ = await notifications.requestAuthorizationIfNeeded()
    }

    public func requestNotificationPermission() async {
        showNotificationPrompt = false
        _ = await notifications.requestAuthorizationIfNeeded()
    }

    public func simulateTestNotification() async {
        _ = await notifications.requestAuthorizationIfNeeded()
        await notifications.schedulePaymentReceived(
            title: "Demo Employer",
            amount: Money(amount: 1250, currencyCode: balance.currencyCode).formatted
        )
    }

    public func refresh() async {
        if let latestCredit = transactions.last(where: { !$0.isDebit }) {
            notifiedCreditIDs.remove(latestCredit.id)
        }
        await load()
        if let latestCredit = transactions.last(where: { !$0.isDebit }) {
            await handleCredit(latestCredit)
        }
    }

    public func load() async {
        if isOffline { return }

        loadTask?.cancel()
        transactions = []
        categorySpend = []
        isBalanceLoading = true
        isWeeklyLoading = true
        isTransactionsLoading = true
        isChartLoading = true
        isInitialStreamLoad = true

        loadTask = Task { [weak self] in
            guard let self else { return }
            await withTaskGroup(of: Void.self) { group in
                group.addTask { await self.fetchBalance() }
                group.addTask { await self.fetchWeeklySpend() }
                group.addTask { await self.fetchAccounts() }
                group.addTask { await self.fetchTransactionsStaggered() }
            }
            self.isInitialStreamLoad = false
            self.refreshCategorySpend()
            self.isChartLoading = false
        }
        await loadTask?.value
    }

    private func fetchBalance() async {
        defer { isBalanceLoading = false }
        guard !Task.isCancelled else { return }
        do {
            let loaded = try await api.fetchBalance()
            balance = loaded
        } catch {}
    }

    private func fetchWeeklySpend() async {
        defer { isWeeklyLoading = false }
        guard !Task.isCancelled else { return }
        do {
            weeklySpend = try await api.fetchWeeklySpend()
        } catch {}
    }

    private func fetchAccounts() async {
        do {
            accounts = try await api.fetchAccounts()
        } catch {}
    }

    private func fetchTransactionsStaggered() async {
        defer { isTransactionsLoading = false }
        guard !Task.isCancelled else { return }
        do {
            try await api.streamTransactions(into: transactionSubject)
        } catch {}
    }

    private func refreshCategorySpend() {
        categorySpend = FinanceCalculator.categorySpend(transactions: transactions)
    }
}
