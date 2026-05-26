import SwiftUI
import SwiftData

struct BudgetsView: View {
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    var body: some View {
        NavigationStack {
            List {
                ForEach(categories) { category in
                    BudgetEditorRow(category: category)
                }
            }
            .navigationTitle("Budgets")
        }
    }
}

private struct BudgetEditorRow: View {
    @Bindable var category: Category

    @State private var budgetText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category.name)
                    .font(.headline)
                if category.isSoftDrinkCategory {
                    Image(systemName: "cup.and.saucer.fill")
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
            }

            HStack {
                Text("Monthly limit")
                    .foregroundStyle(.secondary)
                Spacer()
                TextField("No limit", text: $budgetText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 120)
                    .onAppear { syncFromModel() }
                    .onChange(of: budgetText) { _, newValue in
                        applyBudget(text: newValue)
                    }
            }
            .font(.subheadline)
        }
        .padding(.vertical, 4)
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
