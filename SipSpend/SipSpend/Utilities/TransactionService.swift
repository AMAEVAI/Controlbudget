import Foundation
import SwiftData

enum TransactionService {
    static let minDrinkML = 50
    static let maxDrinkML = 2000

    static func validateDrinkVolume(_ ml: Int) -> Bool {
        (minDrinkML ... maxDrinkML).contains(ml)
    }

    @MainActor
    static func add(
        amount: Decimal,
        date: Date,
        note: String?,
        volumeML: Int?,
        category: Category?,
        account: Account,
        context: ModelContext
    ) throws {
        if let category, category.isSoftDrinkCategory, let volumeML {
            guard validateDrinkVolume(volumeML) else {
                throw TransactionError.invalidVolume
            }
        }

        let transaction = Transaction(
            amount: amount,
            date: date,
            note: note?.isEmpty == true ? nil : note,
            volumeML: volumeML,
            category: category
        )
        context.insert(transaction)
        account.balance += amount
        afterDataChange(context: context)
    }

    @MainActor
    static func remove(_ transaction: Transaction, account: Account, context: ModelContext) {
        account.balance -= transaction.amount
        context.delete(transaction)
        afterDataChange(context: context)
    }

    @MainActor
    private static func afterDataChange(context: ModelContext) {
        WidgetDataStore.sync(context: context)
        Task {
            await BudgetNotificationService.evaluateAll(context: context)
        }
    }
}

enum TransactionError: LocalizedError {
    case invalidVolume

    var errorDescription: String? {
        switch self {
        case .invalidVolume:
            return "Volume must be between \(TransactionService.minDrinkML) and \(TransactionService.maxDrinkML) ml."
        }
    }
}
