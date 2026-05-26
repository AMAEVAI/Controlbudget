import Foundation

enum L10n {
    // MARK: - Tabs
    static var tabHome: String { tr("tab.home", "Home") }
    static var tabAdd: String { tr("tab.add", "Add") }
    static var tabActivity: String { tr("tab.activity", "Activity") }
    static var tabBudgets: String { tr("tab.budgets", "Budgets") }
    static var tabSettings: String { tr("tab.settings", "Settings") }

    // MARK: - Home
    static var appName: String { tr("app.name", "SipSpend") }
    static var balance: String { tr("home.balance", "Balance") }
    static var spentThisMonth: String { tr("home.spent_month", "Spent this month") }
    static var softDrinksWeek: String { tr("home.soft_drinks_week", "Soft drinks this week") }
    static var drinks: String { tr("home.drinks", "Drinks") }
    static var spent: String { tr("home.spent", "Spent") }
    static var volume: String { tr("home.volume", "Volume") }
    static var spendingLast7: String { tr("home.chart_title", "Spending — last 7 days") }
    static var noExpensesWeek: String { tr("home.no_expenses_week", "No expenses yet this week.") }
    static var budgets: String { tr("home.budgets", "Budgets") }
    static var noCategories: String { tr("home.no_categories", "No categories yet.") }
    static var drinkGoal: String { tr("home.drink_goal", "Drink goals") }

    // MARK: - Add
    static var addTitle: String { tr("add.title", "Add") }
    static var type: String { tr("add.type", "Type") }
    static var expense: String { tr("add.expense", "Expense") }
    static var income: String { tr("add.income", "Income") }
    static var amount: String { tr("add.amount", "Amount") }
    static var category: String { tr("add.category", "Category") }
    static var none: String { tr("add.none", "None") }
    static var softDrink: String { tr("add.soft_drink", "Soft drink") }
    static var details: String { tr("add.details", "Details") }
    static var date: String { tr("add.date", "Date") }
    static var noteOptional: String { tr("add.note_optional", "Note (optional)") }
    static var quickLogDrink: String { tr("add.quick_log", "Quick log drink") }
    static var repeatLast: String { tr("add.repeat_last", "Repeat last transaction") }
    static var save: String { tr("add.save", "Save") }
    static var quickAmounts: String { tr("add.quick_amounts", "Quick amounts") }
    static var couldNotSave: String { tr("add.could_not_save", "Could not save") }
    static var ok: String { tr("common.ok", "OK") }
    static var cancel: String { tr("common.cancel", "Cancel") }
    static var unlock: String { tr("common.unlock", "Unlock") }
    static var invalidAmountHint: String { tr("add.invalid_amount", "Set a valid amount first, or enter one above.") }

    // MARK: - Activity
    static var activityTitle: String { tr("activity.title", "Activity") }
    static var noTransactions: String { tr("activity.empty_title", "No transactions") }
    static var noTransactionsHint: String { tr("activity.empty_hint", "Add an expense or income from the Add tab.") }
    static var search: String { tr("activity.search", "Search") }
    static var exportCSV: String { tr("activity.export", "Export CSV") }
    static var uncategorized: String { tr("activity.uncategorized", "Uncategorized") }
    static var editTransaction: String { tr("activity.edit", "Edit transaction") }

    // MARK: - Budgets
    static var budgetsTitle: String { tr("budgets.title", "Budgets") }
    static var monthlyLimit: String { tr("budgets.monthly_limit", "Monthly limit") }
    static var noLimit: String { tr("budgets.no_limit", "No limit") }

    // MARK: - Settings
    static var settingsTitle: String { tr("settings.title", "Settings") }
    static var appearance: String { tr("settings.appearance", "Appearance") }
    static var appearanceSystem: String { tr("settings.appearance_system", "System") }
    static var appearanceLight: String { tr("settings.appearance_light", "Light") }
    static var appearanceDark: String { tr("settings.appearance_dark", "Dark") }
    static var security: String { tr("settings.security", "Security") }
    static var faceIDLock: String { tr("settings.face_id", "Lock with Face ID") }
    static var drinkGoalsSection: String { tr("settings.drink_goals", "Weekly drink goals") }
    static var maxDrinksWeek: String { tr("settings.max_drinks", "Max drinks per week") }
    static var maxSpendWeek: String { tr("settings.max_spend", "Max spend per week (€)") }
    static var reminders: String { tr("settings.reminders", "Reminders") }
    static var eveningReminder: String { tr("settings.evening", "Daily evening reminder (8 PM)") }
    static var data: String { tr("settings.data", "Data") }
    static var languageNote: String { tr("settings.language_note", "Language follows iPhone Settings (English / French).") }
    static var off: String { tr("settings.off", "Off") }

    // MARK: - Onboarding
    static var onboardingNext: String { tr("onboarding.next", "Next") }
    static var onboardingStart: String { tr("onboarding.start", "Get started") }
    static var onboarding1Title: String { tr("onboarding.1.title", "Track your money") }
    static var onboarding1Body: String { tr("onboarding.1.body", "Budgets in euros with clear monthly limits.") }
    static var onboarding2Title: String { tr("onboarding.2.title", "Log soft drinks") }
    static var onboarding2Body: String { tr("onboarding.2.body", "Track count, spend, and milliliters every week.") }
    static var onboarding3Title: String { tr("onboarding.3.title", "Stay in control") }
    static var onboarding3Body: String { tr("onboarding.3.body", "Alerts at 80% and 100% of your budget.") }

    // MARK: - Notifications
    static var budgetWarningTitle: String { tr("notif.budget_warn_title", "Budget almost used") }
    static func budgetWarningBody(_ category: String, spent: String, budget: String) -> String {
        String(format: tr("notif.budget_warn_body", "%@: %@ of %@ this month (80%%+)."), category, spent, budget)
    }
    static var budgetExceededTitle: String { tr("notif.budget_exceed_title", "Budget limit reached") }
    static func budgetExceededBody(_ category: String, budget: String) -> String {
        String(format: tr("notif.budget_exceed_body", "%@: monthly limit %@ reached."), category, budget)
    }
    static var drinkGoalTitle: String { tr("notif.drink_goal_title", "Drink goal reached") }
    static func drinkGoalBody(_ detail: String) -> String {
        String(format: tr("notif.drink_goal_body", "Weekly limit: %@"), detail)
    }
    static var eveningTitle: String { tr("notif.evening_title", "SipSpend reminder") }
    static var eveningBody: String { tr("notif.evening_body", "Log today's expenses and drinks.") }

    // MARK: - Categories (seed)
    static var catSoftDrinks: String { tr("cat.soft_drinks", "Soft Drinks") }
    static var catFood: String { tr("cat.food", "Food") }
    static var catTransport: String { tr("cat.transport", "Transport") }
    static var catOther: String { tr("cat.other", "Other") }

    // MARK: - Errors
    static func volumeRange(_ min: Int, _ max: Int) -> String {
        String(format: tr("error.volume", "Volume must be between %d and %d ml."), min, max)
    }

    private static func tr(_ key: String, _ defaultValue: String) -> String {
        String(localized: String.LocalizationValue(key), defaultValue: defaultValue)
    }
}
