import PulseCore
import PulseDesign
import SwiftUI

// MARK: - Collapsed stack

public struct TransactionStackView: View {
    @ObservedObject var viewModel: TransactionStackViewModel

    public init(viewModel: TransactionStackViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent")
                .font(.headline)
                .foregroundStyle(FintechTheme.textPrimary)

            if viewModel.stackPreview.isEmpty {
                ForEach(0 ..< 3, id: \.self) { _ in
                    TransactionRowSkeleton()
                }
            } else {
                collapsedStack
            }
        }
    }

    private var collapsedStack: some View {
        let items = viewModel.stackPreview
        return Button {
            viewModel.expandToHistory()
            Task { @MainActor in PulseHaptics.light() }
        } label: {
            ZStack(alignment: .top) {
                ForEach(Array(items.enumerated().reversed()), id: \.element.id) { index, tx in
                    let depth = items.count - 1 - index
                    stackCard(tx, depth: depth)
                        .offset(y: CGFloat(depth) * 10)
                        .scaleEffect(scale(for: depth), anchor: .top)
                        .zIndex(Double(items.count - depth))
                        .allowsHitTesting(false)
                }
            }
            .frame(height: stackHeight(for: items.count))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Recent transactions stack")
        .accessibilityHint("Double tap to open transaction history")
    }

    private func stackCard(_ tx: PulseCore.Transaction, depth: Int) -> some View {
        TransactionStackRow(transaction: tx)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(FintechTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(depth == 0 ? 0.35 : 0.2), radius: depth == 0 ? 12 : 6, y: 4)
            .accessibilityHidden(true)
    }

    private func scale(for depth: Int) -> CGFloat {
        switch depth {
        case 0: return 1
        case 1: return 0.95
        default: return 0.90
        }
    }

    private func stackHeight(for count: Int) -> CGFloat {
        72 + CGFloat(max(count - 1, 0)) * 10
    }
}

// MARK: - Full-screen history

public struct TransactionHistoryView: View {
    @ObservedObject var viewModel: TransactionStackViewModel
    let allTransactions: [PulseCore.Transaction]
    let onDismiss: () -> Void

    @State private var selectedTransaction: PulseCore.Transaction?
    @State private var dragOffset: CGFloat = 0

    public init(
        viewModel: TransactionStackViewModel,
        allTransactions: [PulseCore.Transaction],
        onDismiss: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.allTransactions = allTransactions
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.displayedTransactions) { tx in
                    Button {
                        selectedTransaction = tx
                        Task { @MainActor in PulseHaptics.light() }
                    } label: {
                        TransactionStackRow(transaction: tx)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(FintechTheme.background)
                    .listRowSeparatorTint(Color.white.opacity(0.08))
                    .onAppear {
                        Task { await viewModel.loadMoreIfNeeded(currentItem: tx) }
                    }
                }
                if viewModel.isLoadingMore {
                    HStack {
                        Spacer()
                        ProgressView()
                            .tint(FintechTheme.accent)
                        Spacer()
                    }
                    .listRowBackground(FintechTheme.background)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(FintechTheme.background)
            .navigationTitle("Transaction history")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismissHistory()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                    }
                    .foregroundStyle(FintechTheme.textSecondary)
                    .accessibilityLabel("Close transaction history")
                }
            }
            .safeAreaInset(edge: .top, spacing: 0) {
                dragHandle
            }
            .navigationDestination(item: $selectedTransaction) { tx in
                TransactionDetailTransitionView(
                    transactionID: tx.id,
                    transactions: allTransactions
                )
                .navigationBarBackButtonHidden(true)
                .toolbar(.hidden, for: .navigationBar)
            }
        }
        .preferredColorScheme(.dark)
        .offset(y: max(0, dragOffset))
        .gesture(dismissDrag)
    }

    private var dragHandle: some View {
        Capsule()
            .fill(Color.white.opacity(0.35))
            .frame(width: 40, height: 5)
            .padding(.top, 8)
            .padding(.bottom, 4)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
    }

    private var dismissDrag: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 {
                    dragOffset = value.translation.height
                }
            }
            .onEnded { value in
                if value.translation.height > 120 || value.predictedEndTranslation.height > 200 {
                    dismissHistory()
                } else {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.88)) {
                        dragOffset = 0
                    }
                }
            }
    }

    private func dismissHistory() {
        dragOffset = 0
        Task { @MainActor in PulseHaptics.soft() }
        onDismiss()
    }
}

// MARK: - Row

struct TransactionStackRow: View {
    let transaction: PulseCore.Transaction

    var body: some View {
        let money = Money(amount: transaction.amount, currencyCode: transaction.currencyCode)
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(FintechTheme.textPrimary)
                Text(transaction.category)
                    .font(.caption)
                    .foregroundStyle(FintechTheme.textSecondary)
            }
            Spacer()
            Text((transaction.isDebit ? "-" : "+") + money.formatted)
                .font(.body.weight(.semibold))
                .foregroundStyle(transaction.isDebit ? FintechTheme.textPrimary : FintechTheme.accent)
        }
    }
}
