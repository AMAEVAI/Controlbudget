import Foundation

enum AppPreferences {
    static let hasSeenOnboarding = "prefs.hasSeenOnboarding"
    static let biometricLockEnabled = "prefs.biometricLock"
    static let appearanceMode = "prefs.appearance" // 0 system 1 light 2 dark
    static let maxDrinksPerWeek = "prefs.maxDrinksWeek"
    static let maxDrinkEURPerWeek = "prefs.maxDrinkEURWeek"
    static let eveningReminderEnabled = "prefs.eveningReminder"
    static let pendingQuickDrink = "prefs.pendingQuickDrink"

    // Last transaction snapshot for repeat
    static let lastTxAmount = "prefs.lastTx.amount"
    static let lastTxNote = "prefs.lastTx.note"
    static let lastTxVolumeML = "prefs.lastTx.volumeML"
    static let lastTxIsIncome = "prefs.lastTx.isIncome"
    static let lastTxCategoryName = "prefs.lastTx.categoryName"
}

enum AppearanceMode: Int {
    case system = 0
    case light = 1
    case dark = 2
}
