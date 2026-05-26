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

    private let quickAmounts: [Double] = [1, 2.5, 5, 10]

    private var account: Account? { accounts.first }
    private var softDrinkCategory: Category? { categories.first(where: \.isSoftDrinkCategory) }
    private var isSoftDrinkSelected: Bool { selectedCategory?.isSoftDrinkCategory == true }

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
                        Text("€").foregroundStyle(.secondary)
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                    }
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.quickAmounts)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        HStack {
                            ForEach(quickAmounts, id: \.self) { value in
                                Button {
                                    amountText = String(value)
                                    Haptics.lightTap()
                                } label: {
                                    Text(Decimal(value).eurString)
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 8)
                                        .background(DS.Colors.cardAlt, in: RoundedRectangle(cornerRadius: 10))
                                }
                                .buttonStyle(.plain)
                            }
                        }
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

                Section {
                    Button { quickLogDrink() } label: {
                        Label(L10n.quickLogDrink, systemImage: "cup.and.saucer.fill")
                    }
                    .disabled(softDrinkCategory == nil || account == nil)

                    Button { repeatLast() } label: {
                        Label(L10n.repeatLast, systemImage: "arrow.clockwise")
                    }
                    .disabled(account == nil || LastTransactionStore.load() == nil)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle(L10n.addTitle)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.save) { save() }
                        .disabled(!canSave)
                }
            }
            .onAppear {
                if selectedCategory == nil { selectedCategory = categories.first }
                volumeML = lastDrinkVolumeML
            }
            .alert(L10n.couldNotSave, isPresented: $showError) {
                Button(L10n.ok, role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var canSave: Bool {
        account != nil && parsedAmount != nil && (parsedAmount ?? 0) > 0
    }

    private var parsedAmount: Decimal? {
        Decimal(string: amountText.replacingOccurrences(of: ",", with: "."))
    }

    private func save() {
        guard let account, let value = parsedAmount, value > 0 else { return }
        let signed: Decimal = isIncome ? value : -value
        let ml: Int? = (isSoftDrinkSelected && !isIncome) ? volumeML : nil

        do {
            try TransactionService.add(
                amount: signed, date: date, note: note, volumeML: ml,
                category: selectedCategory, account: account, context: modelContext
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
        guard let value = Decimal(string: lastDrinkAmountString.replacingOccurrences(of: ",", with: ".")), value > 0 else {
            errorMessage = L10n.invalidAmountHint
            showError = true
            return
        }
        do {
            try TransactionService.add(
                amount: -value, date: .now, note: nil, volumeML: lastDrinkVolumeML,
                category: category, account: account, context: modelContext
            )
            selectedCategory = category
            volumeML = lastDrinkVolumeML
            Haptics.lightTap()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    private func repeatLast() {
        guard let account, let last = LastTransactionStore.load() else { return }
        let category = categories.first { $0.name == last.categoryName }
        do {
            try TransactionService.add(
                amount: last.amount, date: .now, note: last.note, volumeML: last.volumeML,
                category: category, account: account, context: modelContext
            )
            Haptics.success()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
