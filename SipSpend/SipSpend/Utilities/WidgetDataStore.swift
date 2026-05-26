import Foundation
import SwiftData
import WidgetKit

enum WidgetDataStore {
    @MainActor
    static func sync(context: ModelContext) {
        let descriptor = FetchDescriptor<Transaction>()
        let transactions = (try? context.fetch(descriptor)) ?? []
        update(from: transactions)
    }

    static func update(from transactions: [Transaction]) {
        let summary = SoftDrinkStats.weekSummary(transactions: transactions)
        let snapshot = WidgetDrinkSnapshot(
            count: summary.count,
            spentEUR: (summary.spentEUR as NSDecimalNumber).doubleValue,
            totalML: summary.totalML,
            updatedAt: .now
        )

        guard let defaults = UserDefaults(suiteName: AppGroup.identifier),
              let data = try? JSONEncoder().encode(snapshot)
        else { return }

        defaults.set(data, forKey: AppGroup.drinkSnapshotKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
