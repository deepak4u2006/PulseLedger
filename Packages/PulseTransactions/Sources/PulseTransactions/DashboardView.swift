import Charts
import PulseCore
import PulseDesign
import PulseNetworking
import SwiftUI

public struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    private let detailRouter: TransactionDetailRouter
    private let onSignOut: () -> Void
    private let onResetAppState: () -> Void

    @State private var showSettings = false
    @State private var didHapticFirstRow = false

    public init(
        viewModel: DashboardViewModel,
        detailRouter: TransactionDetailRouter? = nil,
        onSignOut: @escaping () -> Void = {},
        onResetAppState: @escaping () -> Void = {}
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.detailRouter = detailRouter ?? TransactionDetailRouter()
        self.onSignOut = onSignOut
        self.onResetAppState = onResetAppState
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
                        chartSection
                        spendingSection
                        transactionList
                    }
                    .padding()
                }
                .refreshable {
                    await viewModel.refresh()
                    PulseHaptics.soft()
                }
            }
            .navigationTitle("PulseLedger")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                if viewModel.isOffline {
                    ToolbarItem(placement: .topBarLeading) {
                        Image(systemName: "wifi.slash")
                            .foregroundStyle(FintechTheme.danger)
                            .accessibilityLabel("Offline")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(FintechTheme.textSecondary)
                        }
                        .accessibilityLabel("Settings")

                        Button {
                            Task { await viewModel.simulateTestNotification() }
                        } label: {
                            Image(systemName: "bell.fill")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(FintechTheme.textSecondary)
                        }
                        .accessibilityLabel("Test notification")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                settingsSheet
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

    private var settingsSheet: some View {
        NavigationStack {
            List {
                Section("Account") {
                    Button("Sign out", role: .destructive) {
                        showSettings = false
                        onSignOut()
                    }
                }
                Section("Developer") {
                    Button("Simulate payment notification") {
                        Task { await viewModel.simulateTestNotification() }
                    }
                    Button("Reset app state", role: .destructive) {
                        showSettings = false
                        onResetAppState()
                    }
                }
                Section("Alerts") {
                    Button("Enable notification permission") {
                        Task { await viewModel.requestNotificationPermission() }
                    }
                    Toggle(
                        "Payment alerts",
                        isOn: Binding(
                            get: { viewModel.notifications.alertsEnabled },
                            set: { viewModel.notifications.alertsEnabled = $0 }
                        )
                    )
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showSettings = false }
                }
            }
        }
        .presentationDetents([.medium])
        .preferredColorScheme(.dark)
    }

    private var chartSection: some View {
        Group {
            if viewModel.isChartLoading || viewModel.categorySpend.isEmpty {
                ChartCardSkeleton()
            } else {
                CategorySpendChartCard(categories: viewModel.categorySpend)
                    .frame(height: 168)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.isChartLoading)
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

            ForEach(Array(viewModel.transactions.enumerated()), id: \.element.id) { index, tx in
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
                .onAppear {
                    if index == 0, !didHapticFirstRow, !viewModel.isTransactionsLoading {
                        didHapticFirstRow = true
                        PulseHaptics.soft()
                    }
                }
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.82), value: viewModel.transactions.count)
        }
        .onChange(of: viewModel.isTransactionsLoading) { _, loading in
            if loading {
                didHapticFirstRow = false
            }
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

// MARK: - Category spend chart (SwiftUI Charts, iOS 17+)

private struct CategorySpendChartCard: View {
    let categories: [CategorySpend]

    private var chartMinWidth: CGFloat {
        CGFloat(max(categories.count, 1)) * 76
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spend by category")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(FintechTheme.textSecondary)

            ScrollView(.horizontal, showsIndicators: false) {
                Chart(categories, id: \.category) { item in
                    BarMark(
                        x: .value("Category", item.category),
                        y: .value("Spend", amount(for: item))
                    )
                    .foregroundStyle(FintechTheme.accent)
                    .cornerRadius(4)
                }
                .chartYAxis(.hidden)
                .chartXAxis {
                    AxisMarks(position: .bottom) { value in
                        AxisValueLabel(centered: true) {
                            if let category = value.as(String.self) {
                                Text(chartLabel(for: category))
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundStyle(FintechTheme.textSecondary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 72)
                            }
                        }
                    }
                }
                .frame(width: max(chartMinWidth, 280), height: 124)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func amount(for item: CategorySpend) -> Double {
        NSDecimalNumber(decimal: item.amount).doubleValue
    }

    private func chartLabel(for category: String) -> String {
        if category.count <= 14 {
            return category
        }
        switch category {
        case "Entertainment":
            return "Entertain."
        case "Transportation":
            return "Transport"
        default:
            return category
        }
    }
}
