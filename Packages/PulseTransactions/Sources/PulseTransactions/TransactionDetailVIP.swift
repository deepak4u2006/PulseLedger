import Foundation
import PulseCore
import PulseDesign
import SwiftUI

// MARK: - VIP contracts

public struct TransactionDetailDisplayModel: Equatable, Sendable {
    public let title: String
    public let category: String
    public let amountText: String
    public let dateText: String
    public let directionLabel: String
    public let isDebit: Bool

    public init(
        title: String,
        category: String,
        amountText: String,
        dateText: String,
        directionLabel: String,
        isDebit: Bool
    ) {
        self.title = title
        self.category = category
        self.amountText = amountText
        self.dateText = dateText
        self.directionLabel = directionLabel
        self.isDebit = isDebit
    }
}

public protocol TransactionDetailBusinessLogic: Sendable {
    func load(request: TransactionDetailRequest) async -> PulseCore.Transaction
}

public protocol TransactionDetailPresentationLogic: AnyObject, Sendable {
    func present(transaction: PulseCore.Transaction)
}

public protocol TransactionDetailRouting: AnyObject {
    func makeDetailView(transactionID: String, transactions: [PulseCore.Transaction]) -> AnyView
}

// MARK: - Interactor

public struct TransactionDetailRequest: Sendable {
    public let transactionID: String
    public let transactions: [PulseCore.Transaction]

    public init(transactionID: String, transactions: [PulseCore.Transaction]) {
        self.transactionID = transactionID
        self.transactions = transactions
    }
}

public struct TransactionDetailInteractor: TransactionDetailBusinessLogic {
    public init() {}

    public func load(request: TransactionDetailRequest) async -> PulseCore.Transaction {
        try? await Task.sleep(nanoseconds: 150_000_000)
        return request.transactions.first { $0.id == request.transactionID }
            ?? PulseCore.Transaction(
                id: request.transactionID,
                title: "Unknown",
                amount: 0,
                currencyCode: "EUR",
                category: "—",
                date: .now,
                isDebit: true
            )
    }
}

// MARK: - Presenter

@MainActor
public final class TransactionDetailPresenter: TransactionDetailPresentationLogic, ObservableObject {
    @Published public private(set) var display: TransactionDetailDisplayModel?

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()

    public init() {}

    public func present(transaction: PulseCore.Transaction) {
        let money = Money(amount: transaction.amount, currencyCode: transaction.currencyCode)
        let prefix = transaction.isDebit ? "-" : "+"
        display = TransactionDetailDisplayModel(
            title: transaction.title,
            category: transaction.category,
            amountText: prefix + money.formatted,
            dateText: dateFormatter.string(from: transaction.date),
            directionLabel: transaction.isDebit ? "Money out" : "Money in",
            isDebit: transaction.isDebit
        )
    }
}

// MARK: - Router / Worker

@MainActor
public final class TransactionDetailRouter: TransactionDetailRouting {
    private let interactor: TransactionDetailBusinessLogic

    public init(interactor: TransactionDetailBusinessLogic = TransactionDetailInteractor()) {
        self.interactor = interactor
    }

    public func makeDetailView(transactionID: String, transactions: [PulseCore.Transaction]) -> AnyView {
        AnyView(TransactionDetailView(
            transactionID: transactionID,
            transactions: transactions,
            interactor: interactor
        ))
    }
}

// MARK: - View

public struct TransactionDetailView: View {
    @StateObject private var presenter = TransactionDetailPresenter()
    private let transactionID: String
    private let transactions: [PulseCore.Transaction]
    private let interactor: TransactionDetailBusinessLogic

    public init(
        transactionID: String,
        transactions: [PulseCore.Transaction],
        interactor: TransactionDetailBusinessLogic = TransactionDetailInteractor()
    ) {
        self.transactionID = transactionID
        self.transactions = transactions
        self.interactor = interactor
    }

    public var body: some View {
        ZStack {
            FintechTheme.background.ignoresSafeArea()
            if let model = presenter.display {
                VStack(alignment: .leading, spacing: 24) {
                    Text(model.directionLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(model.isDebit ? FintechTheme.textSecondary : FintechTheme.accent)
                    Text(model.amountText)
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(model.isDebit ? FintechTheme.textPrimary : FintechTheme.accent)
                    VStack(alignment: .leading, spacing: 8) {
                        detailRow("To / From", model.title)
                        detailRow("Category", model.category)
                        detailRow("Date", model.dateText)
                    }
                    Spacer()
                }
                .padding(24)
            } else {
                ProgressView().tint(FintechTheme.accent)
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            let tx = await interactor.load(
                request: TransactionDetailRequest(transactionID: transactionID, transactions: transactions)
            )
            presenter.present(transaction: tx)
        }
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundStyle(FintechTheme.textSecondary)
            Text(value).foregroundStyle(FintechTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(FintechTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
