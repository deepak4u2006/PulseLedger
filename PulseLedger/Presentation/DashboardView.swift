import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel

    init(viewModel: DashboardViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    init() {
        _viewModel = StateObject(wrappedValue: DashboardViewModel())
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                FintechTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if viewModel.isOffline {
                            OfflineBanner()
                        }
                        balanceCard
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
                            "Simulate offline",
                            isOn: Binding(
                                get: { viewModel.isOffline },
                                set: { viewModel.setOfflineSimulation($0) }
                            )
                        )
                    } label: {
                        Image(systemName: viewModel.isOffline ? "wifi.slash" : "wifi")
                            .foregroundStyle(FintechTheme.accent)
                    }
                    .accessibilityLabel("Network simulation menu")
                }
            }
            .task {
                await viewModel.load()
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
                    Text(viewModel.balance.formatted)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(FintechTheme.textPrimary)
                    Text("Computed from account + activity")
                        .font(.caption)
                        .foregroundStyle(FintechTheme.accent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(FintechTheme.cardGradient(index: 0))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Total balance, \(viewModel.balance.formatted)")
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
                .accessibilityElement(children: .combine)
                .accessibilityLabel("This week spending, \(viewModel.weeklySpend.formatted)")
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
                transactionRow(tx)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity
                    ))
            }
            .animation(.spring(response: 0.45, dampingFraction: 0.82), value: viewModel.transactions.count)
        }
        .accessibilityLabel("Recent transactions")
    }

    private func transactionRow(_ tx: Transaction) -> some View {
        let money = Money(amount: tx.amount, currencyCode: tx.currencyCode)
        let amountText = (tx.isDebit ? "Debit" : "Credit") + ", " + money.formatted
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(tx.title), \(tx.category), \(amountText)")
        .overlay(alignment: .bottom) {
            Divider().overlay(Color.white.opacity(0.1))
        }
    }
}
