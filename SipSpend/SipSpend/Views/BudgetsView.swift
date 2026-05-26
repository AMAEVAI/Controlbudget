import SwiftUI
import SwiftData

struct BudgetsView: View {
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: DS.Spacing.sm) {
                    ForEach(categories) { category in
                        BudgetEditorRow(category: category)
                    }
                }
                .padding(.horizontal, DS.Spacing.md)
                .padding(.top, DS.Spacing.sm)
                .tabBarScrollPadding()
            }
            .scrollIndicators(.visible)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Budgets")
        }
    }
}

private struct BudgetEditorRow: View {
    @Bindable var category: Category

    @State private var budgetText = ""

    private var spent: Decimal {
        MonthSpend.spent(in: category)
    }

    private var progress: Double {
        MonthSpend.budgetProgress(spent: spent, budget: category.monthlyBudget) ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                Label(category.name, systemImage: category.isSoftDrinkCategory ? "cup.and.saucer.fill" : "creditcard.fill")
                    .font(.headline)
                    .symbolRenderingMode(.hierarchical)
                Spacer()
                Text(spent.eurString)
                    .font(.subheadline.weight(.semibold))
            }

            HStack {
                Text("Monthly limit")
                    .foregroundStyle(.secondary)
                Spacer()
                TextField("No limit", text: $budgetText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 120)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(.background, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    .onAppear { syncFromModel() }
                    .onChange(of: budgetText) { _, newValue in
                        applyBudget(text: newValue)
                    }
            }
            .font(.subheadline)

            if category.monthlyBudget != nil {
                ProgressView(value: min(progress, 1.0))
                    .tint(progress >= 1 ? DS.Colors.danger : DS.Colors.accent)
            }
        }
        .cardStyle()
    }

    private func syncFromModel() {
        if let budget = category.monthlyBudget {
            budgetText = "\(budget)"
        } else {
            budgetText = ""
        }
    }

    private func applyBudget(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            category.monthlyBudget = nil
            return
        }
        let normalized = trimmed.replacingOccurrences(of: ",", with: ".")
        if let value = Decimal(string: normalized), value >= 0 {
            category.monthlyBudget = value == 0 ? nil : value
        }
    }
}

#Preview {
    BudgetsView()
        .modelContainer(for: [Account.self, Category.self, Transaction.self], inMemory: true)
}
