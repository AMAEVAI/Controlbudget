import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \Account.name) private var accounts: [Account]
    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]

    @State private var contentAppeared = false

    private var account: Account? { accounts.first }

    private var monthExpenses: Decimal {
        MonthSpend.totalExpenses(transactions: transactions)
    }

    private var drinkSummary: SoftDrinkWeekSummary {
        SoftDrinkStats.weekSummary(transactions: transactions)
    }

    private var chartPoints: [DailySpendPoint] {
        SpendChartData.last7Days(transactions: transactions)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Spacing.lg) {
                    headerCard
                        .staggeredCardAppear(index: 0, appeared: contentAppeared)

                    spendChartCard
                        .staggeredCardAppear(index: 1, appeared: contentAppeared)

                    softDrinksCard
                        .staggeredCardAppear(index: 2, appeared: contentAppeared)

                    budgetsSection
                        .staggeredCardAppear(index: 3, appeared: contentAppeared)
                }
                .padding(.horizontal, DS.Spacing.md)
                .padding(.top, DS.Spacing.sm)
                .tabBarScrollPadding()
            }
            .scrollIndicators(.visible)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("SipSpend")
            .onAppear {
                contentAppeared = true
            }
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
                .animation(DS.Motion.spring, value: account?.balance)

            HStack(spacing: DS.Spacing.sm) {
                metricChip(title: "Spent this month", value: monthExpenses.eurString)
                    .animation(DS.Motion.spring, value: monthExpenses)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Spacing.lg)
        .background {
            RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                .fill(DS.Colors.card)
                .overlay {
                    RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    DS.Colors.accent.opacity(0.22),
                                    DS.Colors.accent.opacity(0.04),
                                    .clear,
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                        .stroke(.quaternary, lineWidth: 1)
                }
        }
    }

    private var spendChartCard: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Label("Spending — last 7 days", systemImage: "chart.bar.fill")
                .font(.headline)
                .symbolEffect(.bounce, value: contentAppeared)

            if chartPoints.allSatisfy({ $0.amount == 0 }) {
                Text("No expenses yet this week.")
                    .font(.subheadline)
                    .foregroundStyle(DS.Colors.muted)
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .center)
            } else {
                DashboardSpendChart(points: chartPoints)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .subtleCardStyle()
    }

    private var softDrinksCard: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.md) {
            Label("Soft drinks this week", systemImage: "cup.and.saucer.fill")
                .font(.headline)

            HStack(spacing: DS.Spacing.sm) {
                statPill(title: "Drinks", value: "\(drinkSummary.count)")
                    .animation(DS.Motion.spring, value: drinkSummary.count)
                statPill(title: "Spent", value: drinkSummary.spentEUR.eurString)
                    .animation(DS.Motion.spring, value: drinkSummary.spentEUR)
                statPill(title: "Volume", value: drinkSummary.totalML.mlString)
                    .animation(DS.Motion.spring, value: drinkSummary.totalML)
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
                .contentTransition(.numericText())
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
                .contentTransition(.numericText())
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
                ForEach(Array(categories.enumerated()), id: \.offset) { index, category in
                    BudgetProgressRow(category: category, rowIndex: index + 4, parentAppeared: contentAppeared)
                }
            }
        }
    }
}

private struct BudgetProgressRow: View {
    let category: Category
    let rowIndex: Int
    let parentAppeared: Bool

    @State private var animatedProgress: Double = 0

    private var spent: Decimal {
        MonthSpend.spent(in: category)
    }

    private var progress: Double {
        MonthSpend.budgetProgress(spent: spent, budget: category.monthlyBudget) ?? 0
    }

    private var progressColor: Color {
        guard category.monthlyBudget != nil else { return DS.Colors.muted }
        switch progress {
        case 0 ..< 0.7: return DS.Colors.success
        case 0.7 ..< 1.0: return DS.Colors.warning
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
                        .contentTransition(.numericText())
                } else {
                    Text(spent.eurString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if category.monthlyBudget != nil {
                ProgressView(value: animatedProgress)
                    .tint(progressColor)
                    .animation(DS.Motion.spring, value: animatedProgress)
                    .accessibilityLabel("\(category.name) budget")
                    .accessibilityValue("\(Int(progress * 100)) percent used")
            }
        }
        .cardStyle(padding: DS.Spacing.md)
        .staggeredCardAppear(index: rowIndex, appeared: parentAppeared)
        .onAppear { syncProgress(animated: true) }
        .onChange(of: progress) { _, _ in syncProgress(animated: true) }
    }

    private func syncProgress(animated: Bool) {
        let target = min(progress, 1.0)
        if animated {
            withAnimation(DS.Motion.spring) {
                animatedProgress = target
            }
        } else {
            animatedProgress = target
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: [Account.self, Category.self, Transaction.self], inMemory: true)
}
