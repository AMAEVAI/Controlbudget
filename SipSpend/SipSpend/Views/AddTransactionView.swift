import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Account.name) private var accounts: [Account]
    @Query(sort: \Category.sortOrder) private var categories: [Category]

    @AppStorage("lastDrinkAmount") private var lastDrinkAmountString = "2.50"
    @AppStorage("lastDrinkVolumeML") private var lastDrinkVolumeML = 330

    @State private var isIncome = false
    @State private var amountText = ""
    @State private var note = ""
    @State private var date = Date.now
    @State private var selectedCategory: Category?
    @State private var volumeML = 330
    @State private var errorMessage: String?
    @State private var showError = false

    private var account: Account? { accounts.first }

    private var softDrinkCategory: Category? {
        categories.first(where: \.isSoftDrinkCategory)
    }

    private var isSoftDrinkSelected: Bool {
        selectedCategory?.isSoftDrinkCategory == true
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Type", selection: $isIncome) {
                        Text("Expense").tag(false)
                        Text("Income").tag(true)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Amount") {
                    HStack {
                        Text("€")
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .accessibilityLabel("Amount in euros")
                    }
                }

                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("None").tag(Optional<Category>.none)
                        ForEach(categories) { category in
                            Text(category.name).tag(Optional(category))
                        }
                    }
                }

                if isSoftDrinkSelected && !isIncome {
                    Section("Soft drink") {
                        Stepper(value: $volumeML, in: TransactionService.minDrinkML ... TransactionService.maxDrinkML, step: 50) {
                            Text(volumeML.mlString)
                        }
                        .accessibilityLabel("Volume in milliliters")
                    }
                }

                Section("Details") {
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    TextField("Note (optional)", text: $note)
                }

                Section {
                    Button {
                        quickLogDrink()
                    } label: {
                        Label("Quick log drink", systemImage: "cup.and.saucer.fill")
                    }
                    .disabled(softDrinkCategory == nil || account == nil)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Add")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
            .onAppear {
                if selectedCategory == nil {
                    selectedCategory = categories.first
                }
                volumeML = lastDrinkVolumeML
            }
            .alert("Could not save", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
    }

    private var canSave: Bool {
        account != nil && parsedAmount != nil && (parsedAmount ?? 0) > 0
    }

    private var parsedAmount: Decimal? {
        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
        return Decimal(string: normalized)
    }

    private func signedAmount(from value: Decimal) -> Decimal {
        isIncome ? value : -value
    }

    private func save() {
        guard let account, let value = parsedAmount, value > 0 else { return }

        let signed = signedAmount(from: value)
        let ml: Int? = (isSoftDrinkSelected && !isIncome) ? volumeML : nil

        do {
            try TransactionService.add(
                amount: signed,
                date: date,
                note: note,
                volumeML: ml,
                category: selectedCategory,
                account: account,
                context: modelContext
            )

            if isSoftDrinkSelected && !isIncome {
                lastDrinkAmountString = value.description
                lastDrinkVolumeML = volumeML
            }

            amountText = ""
            note = ""
            date = .now
            Haptics.success()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func quickLogDrink() {
        guard let account, let category = softDrinkCategory else { return }

        let normalized = lastDrinkAmountString.replacingOccurrences(of: ",", with: ".")
        guard let value = Decimal(string: normalized), value > 0 else {
            errorMessage = "Set a valid amount first, or enter one above."
            showError = true
            return
        }

        let ml = lastDrinkVolumeML

        do {
            try TransactionService.add(
                amount: -value,
                date: .now,
                note: nil,
                volumeML: ml,
                category: category,
                account: account,
                context: modelContext
            )
            amountText = ""
            note = ""
            selectedCategory = category
            volumeML = ml
            Haptics.lightTap()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

#Preview {
    AddTransactionView()
        .modelContainer(for: [Account.self, Category.self, Transaction.self], inMemory: true)
}
