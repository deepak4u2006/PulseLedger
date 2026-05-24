import Foundation

public struct Transaction: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let amount: Decimal
    public let currencyCode: String
    public let category: String
    public let date: Date
    public let isDebit: Bool

    public init(
        id: String,
        title: String,
        amount: Decimal,
        currencyCode: String,
        category: String,
        date: Date,
        isDebit: Bool
    ) {
        self.id = id
        self.title = title
        self.amount = amount
        self.currencyCode = currencyCode
        self.category = category
        self.date = date
        self.isDebit = isDebit
    }
}

public struct Account: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let currencyCode: String
    public let openingBalance: Decimal
    public let maskedPan: String

    public init(
        id: String,
        name: String,
        currencyCode: String,
        openingBalance: Decimal,
        maskedPan: String = "•••• 4242"
    ) {
        self.id = id
        self.name = name
        self.currencyCode = currencyCode
        self.openingBalance = openingBalance
        self.maskedPan = maskedPan
    }
}

public struct SpendingCategory: Hashable, Sendable {
    public let id: String
    public let name: String
    public let icon: String

    public init(id: String, name: String, icon: String) {
        self.id = id
        self.name = name
        self.icon = icon
    }
}

public struct CategorySpend: Hashable, Sendable {
    public let category: String
    public let amount: Decimal

    public init(category: String, amount: Decimal) {
        self.category = category
        self.amount = amount
    }
}

extension Transaction {
    public init(dto: TransactionDTO) {
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
    public init(dto: AccountDTO, maskedPan: String = "•••• 4242") {
        id = dto.id
        name = dto.name
        currencyCode = dto.currencyCode
        openingBalance = dto.openingBalance
        self.maskedPan = maskedPan
    }
}

extension SpendingCategory {
    public init(dto: CategoryDTO) {
        id = dto.id
        name = dto.name
        icon = dto.icon
    }
}
