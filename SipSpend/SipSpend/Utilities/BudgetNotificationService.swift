import Foundation
import SwiftData
import UserNotifications

enum BudgetAlertLevel: Int {
    case warning = 80
    case exceeded = 100
}

@MainActor
enum BudgetNotificationService {
    private static var defaults: UserDefaults { .standard }

    static func requestAuthorizationIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .notDetermined else { return }
        _ = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
    }

    static func evaluateAll(context: ModelContext) async {
        await requestAuthorizationIfNeeded()

        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            return
        }

        let descriptor = FetchDescriptor<Category>(sortBy: [SortDescriptor(\.sortOrder)])
        guard let categories = try? context.fetch(descriptor) else { return }

        let monthKey = currentMonthKey()

        for category in categories {
            await evaluate(category: category, monthKey: monthKey, center: center)
        }
    }

    private static func evaluate(category: Category, monthKey: String, center: UNUserNotificationCenter) async {
        guard let budget = category.monthlyBudget, budget > 0 else { return }

        let spent = MonthSpend.spent(in: category)
        let spentValue = (spent as NSDecimalNumber).doubleValue
        let budgetValue = (budget as NSDecimalNumber).doubleValue
        guard budgetValue > 0 else { return }

        let ratio = spentValue / budgetValue

        if ratio >= 1.0 {
            await sendIfNeeded(
                level: .exceeded,
                categoryName: category.name,
                spent: spent,
                budget: budget,
                monthKey: monthKey,
                center: center
            )
        } else if ratio >= 0.8 {
            await sendIfNeeded(
                level: .warning,
                categoryName: category.name,
                spent: spent,
                budget: budget,
                monthKey: monthKey,
                center: center
            )
        }
    }

    private static func sendIfNeeded(
        level: BudgetAlertLevel,
        categoryName: String,
        spent: Decimal,
        budget: Decimal,
        monthKey: String,
        center: UNUserNotificationCenter
    ) async {
        let storageKey = "budgetAlert.\(categoryName).\(monthKey).\(level.rawValue)"
        guard !defaults.bool(forKey: storageKey) else { return }

        let content = UNMutableNotificationContent()
        switch level {
        case .warning:
            content.title = "Budget almost used"
            content.body = "\(categoryName): \(spent.eurString) of \(budget.eurString) this month (80%+)."
        case .exceeded:
            content.title = "Budget limit reached"
            content.body = "\(categoryName): monthly limit \(budget.eurString) reached."
        }
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: storageKey,
            content: content,
            trigger: nil
        )

        do {
            try await center.add(request)
            defaults.set(true, forKey: storageKey)
        } catch {
            // Ignore delivery errors; will retry on next expense.
        }
    }

    private static func currentMonthKey() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: .now)
    }
}
