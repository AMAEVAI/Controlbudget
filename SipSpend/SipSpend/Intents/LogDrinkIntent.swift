import AppIntents

struct LogDrinkIntent: AppIntent {
    static var title: LocalizedStringResource = "Log Soft Drink"
    static var description = IntentDescription("Opens SipSpend to log a soft drink quickly.")

    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult {
        PendingActions.requestQuickDrink()
        return .result()
    }
}

struct SipSpendShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: LogDrinkIntent(),
            phrases: [
                "Log drink in \(.applicationName)",
                "Log soft drink with \(.applicationName)",
            ],
            shortTitle: "Log Drink",
            systemImageName: "cup.and.saucer.fill"
        )
    }
}
