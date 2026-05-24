import Foundation

struct Transaction: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let amount: Decimal
    let currencyCode: String
    let category: String
    let date: Date
    let isDebit: Bool
}

struct Account: Hashable, Sendable {
    let id: String
    let name: String
    let currencyCode: String
    let openingBalance: Decimal
}

struct SpendingCategory: Hashable, Sendable {
    let id: String
    let name: String
    let icon: String
}

extension Transaction {
    init(dto: TransactionDTO) {
        id = dto.id
        title = dto.title
        amount = dto.amount
        currencyCode = dto.currencyCode
        category = dto.category
        date = dto.date
        isDebit = dto.isDebit
    }
}

extension Account {
    init(dto: AccountDTO) {
        id = dto.id
        name = dto.name
        currencyCode = dto.currencyCode
        openingBalance = dto.openingBalance
    }
}

extension SpendingCategory {
    init(dto: CategoryDTO) {
        id = dto.id
        name = dto.name
        icon = dto.icon
    }
}
