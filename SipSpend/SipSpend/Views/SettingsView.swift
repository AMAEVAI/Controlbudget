import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]

    @AppStorage(AppPreferences.biometricLockEnabled) private var biometricLockEnabled = false
    @AppStorage(AppPreferences.appearanceMode) private var appearanceModeRaw = AppearanceMode.system.rawValue
    @AppStorage(AppPreferences.maxDrinksPerWeek) private var maxDrinksPerWeek = 0
    @AppStorage(AppPreferences.maxDrinkEURPerWeek) private var maxDrinkEURPerWeek = 0.0
    @AppStorage(AppPreferences.eveningReminderEnabled) private var eveningReminderEnabled = false

    @State private var exportURL: URL?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    BrandLogo(size: 40)
                        .listRowBackground(Color.clear)
                }

                Section(L10n.appearance) {
                    Picker(L10n.appearance, selection: $appearanceModeRaw) {
                        Text(L10n.appearanceSystem).tag(AppearanceMode.system.rawValue)
                        Text(L10n.appearanceLight).tag(AppearanceMode.light.rawValue)
                        Text(L10n.appearanceDark).tag(AppearanceMode.dark.rawValue)
                    }
                    .pickerStyle(.segmented)
                }

                Section(L10n.security) {
                    Toggle(L10n.faceIDLock, isOn: $biometricLockEnabled)
                }

                Section(L10n.drinkGoalsSection) {
                    Stepper(value: $maxDrinksPerWeek, in: 0 ... 50) {
                        HStack {
                            Text(L10n.maxDrinksWeek)
                            Spacer()
                            Text(maxDrinksPerWeek == 0 ? L10n.off : "\(maxDrinksPerWeek)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    HStack {
                        Text(L10n.maxSpendWeek)
                        Spacer()
                        TextField(L10n.off, value: $maxDrinkEURPerWeek, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(maxWidth: 100)
                    }
                }

                Section(L10n.reminders) {
                    Toggle(L10n.eveningReminder, isOn: $eveningReminderEnabled)
                        .onChange(of: eveningReminderEnabled) { _, _ in
                            Task { await EveningReminderService.scheduleIfEnabled() }
                        }
                }

                Section(L10n.data) {
                    Button(L10n.exportCSV) {
                        let csv = CSVExportService.makeCSV(transactions: transactions)
                        exportURL = CSVExportService.temporaryFileURL(csv: csv)
                    }
                    if let exportURL {
                        ShareLink(item: exportURL) {
                            Label(L10n.exportCSV, systemImage: "square.and.arrow.up")
                        }
                    }
                }

                Section {
                    Text(L10n.languageNote)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle(L10n.settingsTitle)
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [Account.self, Category.self, Transaction.self], inMemory: true)
}
