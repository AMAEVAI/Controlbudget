import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Account.name) private var accounts: [Account]
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    @AppStorage("lastDrinkAmount") private var lastDrinkAmountString = "2.50"
    @AppStorage("lastDrinkVolumeML") private var lastDrinkVolumeML = 330

    @State private var selectedTab = 0

    private var account: Account? { accounts.first }
    private var softDrinkCategory: Category? { categories.first(where: \.isSoftDrinkCategory) }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label(L10n.tabHome, systemImage: "house.fill") }
                .tag(0)

            AddTransactionView()
                .tabItem { Label(L10n.tabAdd, systemImage: "plus.circle.fill") }
                .tag(1)

            ActivityView()
                .tabItem { Label(L10n.tabActivity, systemImage: "list.bullet") }
                .tag(2)

            BudgetsView()
                .tabItem { Label(L10n.tabBudgets, systemImage: "chart.bar.doc.horizontal.fill") }
                .tag(3)

            SettingsView()
                .tabItem { Label(L10n.tabSettings, systemImage: "gearshape.fill") }
                .tag(4)
        }
        .tint(DS.Colors.accent)
        .onAppear {
            SeedData.seedIfNeeded(context: modelContext)
            WidgetDataStore.sync(context: modelContext)
            Task {
                await BudgetNotificationService.requestAuthorizationIfNeeded()
                await BudgetNotificationService.evaluateAll(context: modelContext)
                await EveningReminderService.scheduleIfEnabled()
            }
            handlePendingQuickDrink()
        }
        .onChange(of: selectedTab) { _, _ in
            handlePendingQuickDrink()
        }
    }

    private func handlePendingQuickDrink() {
        guard PendingActions.consumeQuickDrinkRequest() else { return }
        guard let account, let category = softDrinkCategory else { return }

        let normalized = lastDrinkAmountString.replacingOccurrences(of: ",", with: ".")
        guard let value = Decimal(string: normalized), value > 0 else {
            selectedTab = 1
            return
        }

        do {
            try TransactionService.add(
                amount: -value,
                date: .now,
                note: nil,
                volumeML: lastDrinkVolumeML,
                category: category,
                account: account,
                context: modelContext
            )
            Haptics.success()
            selectedTab = 0
        } catch {
            selectedTab = 1
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [Account.self, Category.self, Transaction.self], inMemory: true)
}
