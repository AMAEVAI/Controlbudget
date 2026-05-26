import Foundation
import SwiftData

@Model
final class Category {
    var name: String
    var monthlyBudget: Decimal?
    var sortOrder: Int
    var isSoftDrinkCategory: Bool

    @Relationship(deleteRule: .cascade, inverse: \Transaction.category)
    var transactions: [Transaction] = []

    init(
        name: String,
        monthlyBudget: Decimal? = nil,
        sortOrder: Int = 0,
        isSoftDrinkCategory: Bool = false
    ) {
        self.name = name
        self.monthlyBudget = monthlyBudget
        self.sortOrder = sortOrder
        self.isSoftDrinkCategory = isSoftDrinkCategory
    }
}
