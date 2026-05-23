import Foundation
import SwiftData

@Model
final class TransactionRecord {
    @Attribute(.unique) var id: UUID
    var title: String
    var amount: Decimal
    var currencyCode: String
    var category: String
    var date: Date
    var isDebit: Bool

    init(id: UUID = UUID(), title: String, amount: Decimal, currencyCode: String = "EUR",
         category: String, date: Date = .now, isDebit: Bool = true) {
        self.id = id
        self.title = title
        self.amount = amount
        self.currencyCode = currencyCode
        self.category = category
        self.date = date
        self.isDebit = isDebit
    }
}
