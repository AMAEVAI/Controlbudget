import Foundation

enum PendingActions {
    static func requestQuickDrink() {
        UserDefaults.standard.set(true, forKey: AppPreferences.pendingQuickDrink)
    }

    static func consumeQuickDrinkRequest() -> Bool {
        let defaults = UserDefaults.standard
        guard defaults.bool(forKey: AppPreferences.pendingQuickDrink) else { return false }
        defaults.set(false, forKey: AppPreferences.pendingQuickDrink)
        return true
    }
}
