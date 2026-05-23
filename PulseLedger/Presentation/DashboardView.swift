import SwiftUI
import SwiftData

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel

    init(context: ModelContext) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(
            repository: TransactionRepository(context: context)
        ))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                FintechTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        balanceCard
                        spendingSection
                        transactionList
                    }
                    .padding()
                }
            }
            .navigationTitle("PulseLedger")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .task { await viewModel.load() }
        }
        .preferredColorScheme(.dark)
    }

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total balance").font(.subheadline).foregroundStyle(FintechTheme.textSecondary)
            Text(viewModel.balance.formatted)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(FintechTheme.textPrimary)
            Text("Offline-ready · SwiftData cache")
                .font(.caption).foregroundStyle(FintechTheme.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(FintechTheme.cardGradient(index: 0))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Total balance, \(viewModel.balance.formatted)")
        .accessibilityHint("Account balance from offline SwiftData cache")
    }

    private var spendingSection: some View {
        FintechCard {
            HStack {
                VStack(alignment: .leading) {
                    Text("This week").foregroundStyle(FintechTheme.textSecondary)
                    Text("€ 186.40").font(.title2.bold()).foregroundStyle(FintechTheme.textPrimary)
                }
                Spacer()
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.title2).foregroundStyle(FintechTheme.accent)
            }
        }
    }

    private var transactionList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent").font(.headline).foregroundStyle(FintechTheme.textPrimary)
            if viewModel.isLoading {
                ProgressView().tint(FintechTheme.accent)
            }
            ForEach(viewModel.transactions, id: \.id) { tx in
                transactionRow(tx)
            }
        }
        .accessibilityLabel("Recent transactions")
    }

    private func transactionRow(_ tx: TransactionRecord) -> some View {
        let amountText = (tx.isDebit ? "Debit" : "Credit") + ", " +
            Money(amount: tx.amount, currencyCode: tx.currencyCode).formatted
        return HStack {
            VStack(alignment: .leading) {
                Text(tx.title).foregroundStyle(FintechTheme.textPrimary)
                Text(tx.category).font(.caption).foregroundStyle(FintechTheme.textSecondary)
            }
            Spacer()
            Text((tx.isDebit ? "-" : "+") + Money(amount: tx.amount, currencyCode: tx.currencyCode).formatted)
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
