import Foundation
import SwiftData

enum SeedData {
    @MainActor
    static func seedIfNeeded(context: ModelContext) {
        let categoryCount = (try? context.fetchCount(FetchDescriptor<Category>())) ?? 0
        let accountCount = (try? context.fetchCount(FetchDescriptor<Account>())) ?? 0

        guard categoryCount == 0 || accountCount == 0 else { return }

        if accountCount == 0 {
            let account = Account(name: "Main", balance: 0)
            context.insert(account)
        }

        if categoryCount == 0 {
            let categories: [Category] = [
                Category(name: "Soft Drinks", monthlyBudget: 40, sortOrder: 0, isSoftDrinkCategory: true),
                Category(name: "Food", monthlyBudget: 300, sortOrder: 1),
                Category(name: "Transport", monthlyBudget: 120, sortOrder: 2),
                Category(name: "Other", monthlyBudget: 100, sortOrder: 3),
            ]

            for category in categories {
                context.insert(category)
            }
        }
    }
}
