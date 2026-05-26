import SwiftUI
import SwiftData

struct EditTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Category.sortOrder) private var categories: [Category]
    @Query(sort: \Account.name) private var accounts: [Account]

    let transaction: Transaction

    @State private var isIncome: Bool
    @State private var amountText: String
    @State private var note: String
    @State private var date: Date
    @State private var selectedCategory: Category?
    @State private var volumeML: Int
    @State private var errorMessage: String?
    @State private var showError = false

    init(transaction: Transaction) {
        self.transaction = transaction
        _isIncome = State(initialValue: transaction.amount > 0)
        _amountText = State(initialValue: "\(abs(transaction.amount))")
        _note = State(initialValue: transaction.note ?? "")
        _date = State(initialValue: transaction.date)
        _selectedCategory = State(initialValue: transaction.category)
        _volumeML = State(initialValue: transaction.volumeML ?? 330)
    }

    private var account: Account? { accounts.first }

    private var isSoftDrinkSelected: Bool {
        selectedCategory?.isSoftDrinkCategory == true
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(L10n.type, selection: $isIncome) {
                        Text(L10n.expense).tag(false)
                        Text(L10n.income).tag(true)
                    }
                    .pickerStyle(.segmented)
                }

                Section(L10n.amount) {
                    HStack {
                        Text("€")
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(L10n.category) {
                    Picker(L10n.category, selection: $selectedCategory) {
                        Text(L10n.none).tag(Optional<Category>.none)
                        ForEach(categories) { category in
                            Text(category.name).tag(Optional(category))
                        }
                    }
                }

                if isSoftDrinkSelected && !isIncome {
                    Section(L10n.softDrink) {
                        Stepper(value: $volumeML, in: TransactionService.minDrinkML ... TransactionService.maxDrinkML, step: 50) {
                            Text(volumeML.mlString)
                        }
                    }
                }

                Section(L10n.details) {
                    DatePicker(L10n.date, selection: $date, displayedComponents: [.date, .hourAndMinute])
                    TextField(L10n.noteOptional, text: $note)
                }
            }
            .navigationTitle(L10n.editTransaction)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.save) { save() }
                }
            }
            .alert(L10n.couldNotSave, isPresented: $showError) {
                Button(L10n.ok, role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var parsedAmount: Decimal? {
        let normalized = amountText.replacingOccurrences(of: ",", with: ".")
        return Decimal(string: normalized)
    }

    private func save() {
        guard let account, let value = parsedAmount, value > 0 else { return }
        let signed: Decimal = isIncome ? value : -value
        let ml: Int? = (isSoftDrinkSelected && !isIncome) ? volumeML : nil

        do {
            try TransactionService.update(
                transaction,
                newAmount: signed,
                newDate: date,
                newNote: note,
                newVolumeML: ml,
                newCategory: selectedCategory,
                account: account,
                context: modelContext
            )
            Haptics.success()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
