import Foundation

struct SoftDrinkWeekSummary {
    let count: Int
    let spentEUR: Decimal
    let totalML: Int
}

enum SoftDrinkStats {
    private static var calendar: Calendar { .current }

    static func weekSummary(transactions: [Transaction]) -> SoftDrinkWeekSummary {
        let weekDrinks = transactions.filter { tx in
            guard let category = tx.category, category.isSoftDrinkCategory else { return false }
            return calendar.isDate(tx.date, equalTo: .now, toGranularity: .weekOfYear) && tx.amount < 0
        }

        let spent = weekDrinks.map(\.amount).reduce(0, +).magnitude
        let ml = weekDrinks.compactMap(\.volumeML).reduce(0, +)

        return SoftDrinkWeekSummary(count: weekDrinks.count, spentEUR: spent, totalML: ml)
    }
}
