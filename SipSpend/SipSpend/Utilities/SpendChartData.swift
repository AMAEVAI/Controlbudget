import Foundation

struct DailySpendPoint: Identifiable {
    let id = UUID()
    let date: Date
    let label: String
    let amount: Double
}

enum SpendChartData {
    private static var calendar: Calendar { .current }

    /// Expense totals per day for the last 7 calendar days (oldest → newest).
    static func last7Days(transactions: [Transaction]) -> [DailySpendPoint] {
        let today = calendar.startOfDay(for: .now)

        return (0 ..< 7).reversed().map { offset in
            let day = calendar.date(byAdding: .day, value: -offset, to: today) ?? today
            let spent = transactions
                .filter { calendar.isDate($0.date, inSameDayAs: day) && $0.amount < 0 }
                .map(\.amount)
                .reduce(0, +)
                .magnitude

            let label = day.formatted(.dateTime.weekday(.abbreviated))
            let amount = (spent as NSDecimalNumber).doubleValue

            return DailySpendPoint(date: day, label: label, amount: amount)
        }
    }
}
