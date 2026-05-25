import Foundation
import PulseCore

@MainActor
public final class TransactionStackViewModel: ObservableObject {
    public enum StackMode: Equatable {
        case collapsed
        case history
    }

    @Published public private(set) var mode: StackMode = .collapsed
    @Published public private(set) var displayedTransactions: [Transaction] = []
    @Published public private(set) var isLoadingMore = false
    @Published public private(set) var hasMore = true

    public let stackDepth = 4
    public let pageSize = 10

    private var allTransactions: [Transaction] = []
    private var catalog: [Transaction] = []
    private var catalogOffset = 0
    private var visibleCount = 0

    public init() {}

    public var stackPreview: [Transaction] {
        Array(displayedTransactions.prefix(stackDepth))
    }

    public func sync(transactions: [Transaction]) {
        let sorted = transactions.sorted { $0.date > $1.date }
        guard sorted != allTransactions else { return }
        allTransactions = sorted
        rebuildCatalog()
        if visibleCount == 0 {
            visibleCount = min(pageSize, catalog.count)
        } else {
            visibleCount = min(max(visibleCount, pageSize), catalog.count)
        }
        refreshDisplayed()
    }

    public func expandToHistory() {
        guard mode == .collapsed else { return }
        mode = .history
    }

    public func collapseToStack() {
        guard mode == .history else { return }
        mode = .collapsed
    }

    public func loadMoreIfNeeded(currentItem: Transaction) async {
        guard mode == .history, hasMore, !isLoadingMore else { return }
        guard let index = displayedTransactions.firstIndex(where: { $0.id == currentItem.id }) else { return }
        guard index >= displayedTransactions.count - 3 else { return }
        await loadNextPage()
    }

    public func loadNextPage() async {
        guard hasMore, !isLoadingMore else { return }
        isLoadingMore = true
        try? await Task.sleep(nanoseconds: 350_000_000)
        let nextEnd = min(visibleCount + pageSize, catalog.count)
        if nextEnd > visibleCount {
            visibleCount = nextEnd
        } else {
            catalogOffset = (catalogOffset + pageSize) % max(catalog.count, 1)
            rebuildCatalog()
            visibleCount = min(pageSize, catalog.count)
        }
        hasMore = catalog.count > pageSize || catalogOffset > 0
        refreshDisplayed()
        isLoadingMore = false
    }

    private func rebuildCatalog() {
        guard !allTransactions.isEmpty else {
            catalog = []
            return
        }
        if catalogOffset == 0 {
            catalog = allTransactions
            return
        }
        let pivot = catalogOffset % allTransactions.count
        catalog = Array(allTransactions[pivot...]) + Array(allTransactions[..<pivot])
    }

    private func refreshDisplayed() {
        displayedTransactions = Array(catalog.prefix(visibleCount))
        hasMore = visibleCount < catalog.count || allTransactions.count > pageSize
    }
}
