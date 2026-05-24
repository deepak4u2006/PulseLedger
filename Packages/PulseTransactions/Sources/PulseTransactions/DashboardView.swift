import PulseBridge
import PulseCore
import PulseDesign
import PulseNetworking
import SwiftUI

public struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    private let detailRouter: TransactionDetailRouter

    public init(viewModel: DashboardViewModel, detailRouter: TransactionDetailRouter? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.detailRouter = detailRouter ?? TransactionDetailRouter()
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                FintechTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if viewModel.isOffline {
                            OfflineBanner()
                        }
                        if !viewModel.accounts.isEmpty {
                            MagneticCardCarousel(
                                accounts: viewModel.accounts,
                                selectedIndex: $viewModel.selectedCardIndex
                            )
                        }
                        balanceCard
                        if !viewModel.categorySpend.isEmpty {
                            CategoryBarChartBridge(
                                categories: viewModel.categorySpend,
                                currencyCode: viewModel.balance.currencyCode
                            )
                            .frame(height: 140)
                        }
                        spendingSection
                        transactionList
                    }
                    .padding()
                }
                .refreshable {
                    await viewModel.refresh()
                }
            }
            .navigationTitle("PulseLedger")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Toggle(
                            "Payment alerts",
                            isOn: Binding(
                                get: { viewModel.notifications.alertsEnabled },
                                set: { viewModel.notifications.alertsEnabled = $0 }
                            )
                        )
                    } label: {
                        Image(systemName: "bell.badge")
                            .foregroundStyle(FintechTheme.accent)
                    }
                }
            }
            .task {
                await viewModel.load()
                await viewModel.notifications.refreshStatus()
            }
            .alert("Enable payment alerts?", isPresented: $viewModel.showNotificationPrompt) {
                Button("Enable") {
                    Task { await viewModel.confirmNotificationPermission() }
                }
                Button("Not now", role: .cancel) {
                    viewModel.showNotificationPrompt = false
                }
            } message: {
                Text("Get notified when income hits your account.")
            }
        }
        .preferredColorScheme(.dark)
    }

    private var balanceCard: some View {
        Group {
            if viewModel.isBalanceLoading {
                BalanceCardSkeleton()
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Total balance")
                        .font(.subheadline)
                        .foregroundStyle(FintechTheme.textSecondary)
                    AnimatedBalanceText(money: viewModel.balance)
                    Text("Computed from account + activity")
                        .font(.caption)
                        .foregroundStyle(FintechTheme.accent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(FintechTheme.cardGradient(index: 0))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.isBalanceLoading)
    }

    private var spendingSection: some View {
        Group {
            if viewModel.isWeeklyLoading {
                WeeklyCardSkeleton()
            } else {
                FintechCard {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("This week")
                                .foregroundStyle(FintechTheme.textSecondary)
                            Text(viewModel.weeklySpend.formatted)
                                .font(.title2.bold())
                                .foregroundStyle(FintechTheme.textPrimary)
                        }
                        Spacer()
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.title2)
                            .foregroundStyle(FintechTheme.accent)
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.isWeeklyLoading)
    }

    private var transactionList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent")
                .font(.headline)
                .foregroundStyle(FintechTheme.textPrimary)

            if viewModel.isTransactionsLoading && viewModel.transactions.isEmpty {
                ForEach(0 ..< 4, id: \.self) { _ in
                    TransactionRowSkeleton()
                }
            }

            ForEach(viewModel.transactions) { tx in
                NavigationLink {
                    detailRouter.makeDetailView(
                        transactionID: tx.id,
                        transactions: viewModel.transactions
                    )
                } label: {
                    transactionRow(tx)
                }
                .buttonStyle(.plain)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.82), value: viewModel.transactions.count)
        }
    }

    private func transactionRow(_ tx: PulseCore.Transaction) -> some View {
        let money = Money(amount: tx.amount, currencyCode: tx.currencyCode)
        return HStack {
            VStack(alignment: .leading) {
                Text(tx.title)
                    .foregroundStyle(FintechTheme.textPrimary)
                Text(tx.category)
                    .font(.caption)
                    .foregroundStyle(FintechTheme.textSecondary)
            }
            Spacer()
            Text((tx.isDebit ? "-" : "+") + money.formatted)
                .foregroundStyle(tx.isDebit ? FintechTheme.textPrimary : FintechTheme.accent)
        }
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            Divider().overlay(Color.white.opacity(0.1))
        }
    }
}
