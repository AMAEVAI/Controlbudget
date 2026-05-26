import Foundation
import UserNotifications

enum EveningReminderService {
    private static let identifier = "sipspend.evening.reminder"

    static func scheduleIfEnabled() async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [identifier])

        guard UserDefaults.standard.bool(forKey: AppPreferences.eveningReminderEnabled) else { return }

        await BudgetNotificationService.requestAuthorizationIfNeeded()

        var date = DateComponents()
        date.hour = 20
        date.minute = 0

        let content = UNMutableNotificationContent()
        content.title = L10n.eveningTitle
        content.body = L10n.eveningBody
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        try? await center.add(request)
    }
}
