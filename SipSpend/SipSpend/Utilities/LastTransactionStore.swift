import Foundation

struct LastTransactionSnapshot {
    let amount: Decimal
    let note: String?
    let volumeML: Int?
    let isIncome: Bool
    let categoryName: String?
}

enum LastTransactionStore {
    private static var defaults: UserDefaults { .standard }

    static func save(from transaction: Transaction) {
        defaults.set(transaction.amount.description, forKey: AppPreferences.lastTxAmount)
        defaults.set(transaction.note, forKey: AppPreferences.lastTxNote)
        if let ml = transaction.volumeML {
            defaults.set(ml, forKey: AppPreferences.lastTxVolumeML)
        } else {
            defaults.removeObject(forKey: AppPreferences.lastTxVolumeML)
        }
        defaults.set(transaction.amount > 0, forKey: AppPreferences.lastTxIsIncome)
        defaults.set(transaction.category?.name, forKey: AppPreferences.lastTxCategoryName)
    }

    static func load() -> LastTransactionSnapshot? {
        guard let amountString = defaults.string(forKey: AppPreferences.lastTxAmount),
              let amount = Decimal(string: amountString)
        else { return nil }

        let note = defaults.string(forKey: AppPreferences.lastTxNote)
        let volumeML: Int? = defaults.object(forKey: AppPreferences.lastTxVolumeML) as? Int
        let isIncome = defaults.bool(forKey: AppPreferences.lastTxIsIncome)
        let categoryName = defaults.string(forKey: AppPreferences.lastTxCategoryName)

        return LastTransactionSnapshot(
            amount: amount,
            note: note,
            volumeML: volumeML,
            isIncome: isIncome,
            categoryName: categoryName
        )
    }
}
