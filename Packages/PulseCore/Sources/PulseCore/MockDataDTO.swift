import Foundation

public struct MockDataRootDTO: Decodable, Sendable {
    public let accounts: [AccountDTO]
    public let categories: [CategoryDTO]
    public let transactions: [TransactionDTO]
}

public struct AccountDTO: Decodable, Sendable {
    public let id: String
    public let name: String
    public let currencyCode: String
    public let openingBalance: Decimal
}

public struct CategoryDTO: Decodable, Sendable {
    public let id: String
    public let name: String
    public let icon: String
}

public struct TransactionDTO: Decodable, Sendable {
    public let id: String
    public let title: String
    public let amount: Decimal
    public let currencyCode: String
    public let category: String
    public let date: Date
    public let isDebit: Bool
}
