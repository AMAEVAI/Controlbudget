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
                VStack(alignment: .leading, spacing: 20) {
                    balanceCard
                    monthSpendCard
                    softDrinksCard
                    budgetsSection
                }
                .padding()
            }
            .navigationTitle("SipSpend")
        }
    }

    private var balanceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Balance")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(account?.balance.eurString ?? "€0.00")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .accessibilityLabel("Account balance")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var monthSpendCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Spent this month")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(monthExpenses.eurString)
                .font(.title2.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var softDrinksCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Soft drinks this week", systemImage: "cup.and.saucer.fill")
                .font(.headline)

            HStack(spacing: 16) {
                statPill(title: "Drinks", value: "\(drinkSummary.count)")
                statPill(title: "Spent", value: drinkSummary.spentEUR.eurString)
                statPill(title: "Volume", value: drinkSummary.totalML.mlString)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private func statPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var budgetsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Budgets")
                .font(.headline)

            if categories.isEmpty {
                Text("No categories yet.")
                    .foregroundStyle(.secondary)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(category.name)
                    .font(.subheadline.bold())
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
                ProgressView(value: progress)
                    .accessibilityLabel("\(category.name) budget")
                    .accessibilityValue("\(Int(progress * 100)) percent used")
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [Account.self, Category.self, Transaction.self], inMemory: true)
}
