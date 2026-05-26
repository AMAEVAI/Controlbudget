import Foundation

enum AppGroup {
    static let identifier = "group.amaev.SipSpend"
    static let drinkSnapshotKey = "widget.drinkWeek"
}

struct WidgetDrinkSnapshot: Codable {
    var count: Int
    var spentEUR: Double
    var totalML: Int
    var updatedAt: Date
}

enum WidgetSnapshotReader {
    static func load() -> WidgetDrinkSnapshot? {
        guard let defaults = UserDefaults(suiteName: AppGroup.identifier),
              let data = defaults.data(forKey: AppGroup.drinkSnapshotKey)
        else { return nil }
        return try? JSONDecoder().decode(WidgetDrinkSnapshot.self, from: data)
    }
}
