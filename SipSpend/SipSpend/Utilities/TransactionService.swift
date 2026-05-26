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
        LastTransactionStore.save(from: transaction)
        afterDataChange(context: context)
    }

    @MainActor
    static func update(
        _ transaction: Transaction,
        newAmount: Decimal,
        newDate: Date,
        newNote: String?,
        newVolumeML: Int?,
        newCategory: Category?,
        account: Account,
        context: ModelContext
    ) throws {
        if let newCategory, newCategory.isSoftDrinkCategory, let newVolumeML {
            guard validateDrinkVolume(newVolumeML) else {
                throw TransactionError.invalidVolume
            }
        }

        account.balance -= transaction.amount
        transaction.amount = newAmount
        transaction.date = newDate
        transaction.note = newNote?.isEmpty == true ? nil : newNote
        transaction.volumeML = newVolumeML
        transaction.category = newCategory
        account.balance += newAmount

        LastTransactionStore.save(from: transaction)
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
        let descriptor = FetchDescriptor<Transaction>()
        let transactions = (try? context.fetch(descriptor)) ?? []
        Task {
            await BudgetNotificationService.evaluateAll(context: context)
            await DrinkGoalService.evaluate(transactions: transactions)
            await EveningReminderService.scheduleIfEnabled()
        }
    }
}

enum TransactionError: LocalizedError {
    case invalidVolume

    var errorDescription: String? {
        switch self {
        case .invalidVolume:
            return L10n.volumeRange(TransactionService.minDrinkML, TransactionService.maxDrinkML)
        }
    }
}
