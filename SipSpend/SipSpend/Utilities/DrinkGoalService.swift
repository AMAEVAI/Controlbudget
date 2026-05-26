import Foundation
import UserNotifications

enum DrinkGoalService {
    private static let notifiedKey = "drinkGoal.notified.week"

    @MainActor
    static func evaluate(transactions: [Transaction]) async {
        let summary = SoftDrinkStats.weekSummary(transactions: transactions)
        let defaults = UserDefaults.standard

        let maxDrinks = defaults.integer(forKey: AppPreferences.maxDrinksPerWeek)
        let maxEUR = defaults.double(forKey: AppPreferences.maxDrinkEURPerWeek)

        guard maxDrinks > 0 || maxEUR > 0 else { return }

        let weekKey = weekIdentifier()
        if defaults.string(forKey: notifiedKey) == weekKey { return }

        var exceeded = false
        var detail = ""

        if maxDrinks > 0, summary.count >= maxDrinks {
            exceeded = true
            detail = "\(summary.count)/\(maxDrinks) \(L10n.drinks.lowercased())"
        }

        let spentValue = (summary.spentEUR as NSDecimalNumber).doubleValue
        if maxEUR > 0, spentValue >= maxEUR {
            exceeded = true
            if !detail.isEmpty { detail += " · " }
            detail += "\(summary.spentEUR.eurString) / \(Decimal(maxEUR).eurString)"
        }

        guard exceeded else { return }

        await BudgetNotificationService.requestAuthorizationIfNeeded()
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = L10n.drinkGoalTitle
        content.body = L10n.drinkGoalBody(detail)
        content.sound = .default

        try? await center.add(UNNotificationRequest(identifier: "drinkGoal.\(weekKey)", content: content, trigger: nil))
        defaults.set(weekKey, forKey: notifiedKey)
    }

    private static func weekIdentifier() -> String {
        let week = Calendar.current.component(.weekOfYear, from: .now)
        let year = Calendar.current.component(.yearForWeekOfYear, from: .now)
        return "\(year)-W\(week)"
    }
}
