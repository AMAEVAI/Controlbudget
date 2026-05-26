import SwiftUI
import SwiftData

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "chart.pie.fill")
                }

            AddTransactionView()
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }

            ActivityView()
                .tabItem {
                    Label("Activity", systemImage: "list.bullet")
                }

            BudgetsView()
                .tabItem {
                    Label("Budgets", systemImage: "dial.medium.fill")
                }
        }
        .onAppear {
            SeedData.seedIfNeeded(context: modelContext)
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: [Account.self, Category.self, Transaction.self], inMemory: true)
}
