import Foundation

struct MockDataRootDTO: Decodable, Sendable {
    let accounts: [AccountDTO]
    let categories: [CategoryDTO]
    let transactions: [TransactionDTO]
}

struct AccountDTO: Decodable, Sendable {
    let id: String
    let name: String
    let currencyCode: String
    let openingBalance: Decimal
}

struct CategoryDTO: Decodable, Sendable {
    let id: String
    let name: String
    let icon: String
}

struct TransactionDTO: Decodable, Sendable {
    let id: String
    let title: String
    let amount: Decimal
    let currencyCode: String
    let category: String
    let date: Date
    let isDebit: Bool
}
