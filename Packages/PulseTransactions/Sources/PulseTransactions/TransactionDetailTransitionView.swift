import PulseCore
import PulseDesign
import SwiftUI

/// Custom full-screen transaction detail with hero header + bottom sheet (no NavigationLink push).
public struct TransactionDetailTransitionView: View {
    @StateObject private var presenter = TransactionDetailPresenter()
    @Environment(\.dismiss) private var dismiss

    private let transactionID: String
    private let transactions: [PulseCore.Transaction]
    private let interactor: TransactionDetailBusinessLogic

    @State private var headerOffset: CGFloat = -320
    @State private var panelOffset: CGFloat = 500
    @State private var panelDrag: CGFloat = 0
    @State private var isVisible = false

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
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                FintechTheme.background.ignoresSafeArea()

                if let model = presenter.display {
                    heroHeader(model, height: proxy.size.height * 0.40)
                        .offset(y: headerOffset)
                        .frame(maxHeight: .infinity, alignment: .top)

                    detailPanel(model, height: proxy.size.height * 0.58)
                        .offset(y: panelOffset + max(0, panelDrag))
                        .frame(maxHeight: .infinity, alignment: .bottom)
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            loadTransaction()
            enterAnimation()
        }
    }

    private func loadTransaction() {
        let request = TransactionDetailRequest(transactionID: transactionID, transactions: transactions)
        let transaction = interactor.load(request: request)
        presenter.present(transaction: transaction)
    }

    private func enterAnimation() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.78)) {
            headerOffset = 0
        }
        withAnimation(.spring(response: 0.62, dampingFraction: 0.8)) {
            panelOffset = 0
        }
    }

    private func dismissDetail() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
            headerOffset = -320
            panelOffset = 500
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.32) {
            dismiss()
        }
    }

    private func heroHeader(_ model: TransactionDetailDisplayModel, height: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [
                    Color(red: 0.08, green: 0.10, blue: 0.18),
                    Color(red: 0.04, green: 0.05, blue: 0.09),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Button {
                        dismissDetail()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(FintechTheme.textPrimary)
                            .padding(10)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                    Spacer()
                }

                Spacer()

                Text(model.directionLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(model.isDebit ? FintechTheme.textSecondary : FintechTheme.accent)

                Text(model.amountText)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(model.isDebit ? FintechTheme.textPrimary : FintechTheme.accent)

                Text(model.title)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(FintechTheme.textPrimary)

                Text(model.dateText)
                    .font(.subheadline)
                    .foregroundStyle(FintechTheme.textSecondary)
            }
            .padding(24)
            .padding(.top, 8)
        }
        .frame(height: height)
        .ignoresSafeArea(edges: .top)
    }

    private func detailPanel(_ model: TransactionDetailDisplayModel, height: CGFloat) -> some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.white.opacity(0.25))
                .frame(width: 36, height: 5)
                .padding(.top, 12)
                .padding(.bottom, 16)

            ScrollView {
                VStack(spacing: 12) {
                    detailRow("Category", model.category)
                    detailRow("Type", model.directionLabel)
                    detailRow("Reference", transactionID)
                    detailRow("Merchant", model.title)
                    detailRow("Date", model.dateText)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(FintechTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .gesture(panelDismissDrag)
    }

    private var panelDismissDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 {
                    panelDrag = value.translation.height
                }
            }
            .onEnded { value in
                if value.translation.height > 100 {
                    dismissDetail()
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                        panelDrag = 0
                    }
                }
            }
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(FintechTheme.textSecondary)
            Text(value)
                .font(.body)
                .foregroundStyle(FintechTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
