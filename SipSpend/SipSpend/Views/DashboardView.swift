import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \Account.name) private var accounts: [Account]
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]

    private var account: Account? { accounts.first }

    private var monthExpenses: Decimal {
        MonthSpend.totalExpenses(transactions: transactions)
    }

    private var drinkSummary: SoftDrinkWeekSummary {
        SoftDrinkStats.weekSummary(transactions: transactions)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                    headerCard
                    softDrinksCard
                    budgetsSection
                }
                .padding(.horizontal, DS.Spacing.md)
                .padding(.vertical, DS.Spacing.sm)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("SipSpend")
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Text("Balance")
                .font(.subheadline)
                .foregroundStyle(DS.Colors.muted)

            Text(account?.balance.eurString ?? "€0.00")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .contentTransition(.numericText())

            HStack(spacing: DS.Spacing.sm) {
                metricChip(title: "Spent this month", value: monthExpenses.eurString)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle(padding: DS.Spacing.lg)
    }

    private var softDrinksCard: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Label("Soft drinks this week", systemImage: "cup.and.saucer.fill")
                .font(.headline)

            HStack(spacing: DS.Spacing.sm) {
                statPill(title: "Drinks", value: "\(drinkSummary.count)")
                statPill(title: "Spent", value: drinkSummary.spentEUR.eurString)
                statPill(title: "Volume", value: drinkSummary.totalML.mlString)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .subtleCardStyle()
    }

    private func metricChip(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(DS.Colors.muted)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Spacing.sm)
        .background(.background, in: RoundedRectangle(cornerRadius: DS.Radius.pill, style: .continuous))
    }

    private func statPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(DS.Colors.muted)
            Text(value)
                .font(.subheadline.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Spacing.sm)
        .background(.background, in: RoundedRectangle(cornerRadius: DS.Radius.pill, style: .continuous))
    }

    private var budgetsSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("Budgets")
                .font(.headline)

            if categories.isEmpty {
                Text("No categories yet.")
                    .foregroundStyle(.secondary)
                    .cardStyle()
            } else {
                ForEach(categories) { category in
                    BudgetProgressRow(category: category)
                }
            }
        }
    }
}

private struct BudgetProgressRow: View {
    let category: Category

    private var spent: Decimal {
        MonthSpend.spent(in: category)
    }

    private var progress: Double {
        MonthSpend.budgetProgress(spent: spent, budget: category.monthlyBudget) ?? 0
    }

    private var progressColor: Color {
        guard category.monthlyBudget != nil else { return DS.Colors.muted }
        switch progress {
        case 0..<0.7: return DS.Colors.success
        case 0.7..<1.0: return DS.Colors.warning
        default: return DS.Colors.danger
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                Label(category.name, systemImage: category.isSoftDrinkCategory ? "cup.and.saucer.fill" : "circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .symbolRenderingMode(.hierarchical)
                Spacer()
                if let budget = category.monthlyBudget {
                    Text("\(spent.eurString) / \(budget.eurString)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(spent.eurString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if category.monthlyBudget != nil {
                ProgressView(value: min(progress, 1.0))
                    .tint(progressColor)
                    .accessibilityLabel("\(category.name) budget")
                    .accessibilityValue("\(Int(progress * 100)) percent used")
            }
        }
        .cardStyle(padding: DS.Spacing.md)
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [Account.self, Category.self, Transaction.self], inMemory: true)
}
