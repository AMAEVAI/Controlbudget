import SwiftUI
import WidgetKit

struct DrinkWeekEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetDrinkSnapshot?
}

struct DrinkWeekProvider: TimelineProvider {
    func placeholder(in context: Context) -> DrinkWeekEntry {
        DrinkWeekEntry(
            date: .now,
            snapshot: WidgetDrinkSnapshot(count: 2, spentEUR: 5.0, totalML: 660, updatedAt: .now)
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (DrinkWeekEntry) -> Void) {
        completion(DrinkWeekEntry(date: .now, snapshot: WidgetSnapshotReader.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DrinkWeekEntry>) -> Void) {
        let entry = DrinkWeekEntry(date: .now, snapshot: WidgetSnapshotReader.load())
        let refresh = Calendar.current.date(byAdding: .hour, value: 1, to: .now) ?? .now.addingTimeInterval(3600)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}

struct DrinkWeekWidgetView: View {
    let entry: DrinkWeekEntry

    private var isFrench: Bool {
        Locale.current.language.languageCode?.identifier == "fr"
    }

    private var widgetTitle: String { isFrench ? "Boissons" : "Soft drinks" }
    private var widgetDrinks: String { isFrench ? "Boissons" : "Drinks" }
    private var widgetSpent: String { isFrench ? "Dépensé" : "Spent" }
    private var widgetVolume: String { isFrench ? "Volume" : "Volume" }
    private var widgetOpenApp: String { isFrench ? "Ouvrez SipSpend" : "Open SipSpend to sync" }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(widgetTitle, systemImage: "cup.and.saucer.fill")
                .font(.headline)
                .foregroundStyle(.primary)

            if let snapshot = entry.snapshot {
                HStack(spacing: 8) {
                    widgetStat(title: widgetDrinks, value: "\(snapshot.count)")
                    widgetStat(title: widgetSpent, value: formatEUR(snapshot.spentEUR))
                    widgetStat(title: widgetVolume, value: "\(snapshot.totalML) ml")
                }
            } else {
                Text(widgetOpenApp)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color.accentColor.opacity(0.25), Color(uiColor: .secondarySystemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private func widgetStat(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formatEUR(_ value: Double) -> String {
        value.formatted(.currency(code: "EUR").precision(.fractionLength(2)))
    }
}

struct DrinkWeekWidget: Widget {
    let kind = "DrinkWeekWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DrinkWeekProvider()) { entry in
            DrinkWeekWidgetView(entry: entry)
        }
        .configurationDisplayName("Soft drinks this week")
        .description("Drinks count, spend, and volume for the current week.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    DrinkWeekWidget()
} timeline: {
    DrinkWeekEntry(
        date: .now,
        snapshot: WidgetDrinkSnapshot(count: 4, spentEUR: 9.5, totalML: 1320, updatedAt: .now)
    )
}
