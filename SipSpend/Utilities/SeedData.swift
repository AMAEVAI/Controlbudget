import Foundation
import SwiftData

enum SeedData {
    private static let seededKey = "didSeedSipSpend"

    @MainActor
    static func seedIfNeeded(context: ModelContext) {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: seededKey) else { return }

        let account = Account(name: "Main", balance: 0)
        context.insert(account)

        let categories: [Category] = [
            Category(name: "Soft Drinks", monthlyBudget: 40, sortOrder: 0, isSoftDrinkCategory: true),
            Category(name: "Food", monthlyBudget: 300, sortOrder: 1),
            Category(name: "Transport", monthlyBudget: 120, sortOrder: 2),
            Category(name: "Other", monthlyBudget: 100, sortOrder: 3),
        ]

        for category in categories {
            context.insert(category)
        }

        defaults.set(true, forKey: seededKey)
    }
}
