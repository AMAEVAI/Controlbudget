import Foundation

enum MonthSpend {
    private static var calendar: Calendar { .current }

    static func spent(in category: Category, month: Date = .now) -> Decimal {
        category.transactions
            .filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) && $0.amount < 0 }
            .map(\.amount)
            .reduce(0, +)
            .magnitude
    }

    static func totalExpenses(transactions: [Transaction], month: Date = .now) -> Decimal {
        transactions
            .filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) && $0.amount < 0 }
            .map(\.amount)
            .reduce(0, +)
            .magnitude
    }

    static func budgetProgress(spent: Decimal, budget: Decimal?) -> Double? {
        guard let budget, budget > 0 else { return nil }
        let ratio = (spent as NSDecimalNumber).doubleValue / (budget as NSDecimalNumber).doubleValue
        return min(ratio, 1.0)
    }
}
