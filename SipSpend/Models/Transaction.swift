import Foundation
import SwiftData

@Model
final class Transaction {
    var amount: Decimal
    var date: Date
    var note: String?
    var volumeML: Int?

    var category: Category?

    init(
        amount: Decimal,
        date: Date = .now,
        note: String? = nil,
        volumeML: Int? = nil,
        category: Category? = nil
    ) {
        self.amount = amount
        self.date = date
        self.note = note
        self.volumeML = volumeML
        self.category = category
    }

    var isExpense: Bool { amount < 0 }
    var isIncome: Bool { amount > 0 }
}
