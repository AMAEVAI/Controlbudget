import SwiftUI
import SwiftData

struct ActivityView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Account.name) private var accounts: [Account]
    @Query(sort: \Transaction.date, order: .reverse) private var transactions: [Transaction]

    private var account: Account? { accounts.first }

    var body: some View {
        NavigationStack {
            Group {
                if transactions.isEmpty {
                    ContentUnavailableView(
                        "No transactions",
                        systemImage: "tray",
                        description: Text("Add an expense or income from the Add tab.")
                    )
                } else {
                    List {
                        ForEach(transactions) { transaction in
                            TransactionRow(transaction: transaction)
                        }
                        .onDelete(perform: delete)
                    }
                }
            }
            .navigationTitle("Activity")
        }
    }

    private func delete(at offsets: IndexSet) {
        guard let account else { return }
        for index in offsets {
            let transaction = transactions[index]
            TransactionService.remove(transaction, account: account, context: modelContext)
        }
    }
}

private struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.category?.name ?? "Uncategorized")
                    .font(.headline)
                Text(transaction.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                if let ml = transaction.volumeML {
                    Text(ml.mlString)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            Text(transaction.amount.eurString)
                .font(.subheadline.bold())
                .foregroundColor(transaction.amount < 0 ? .primary : .green)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ActivityView()
        .modelContainer(for: [Account.self, Category.self, Transaction.self], inMemory: true)
}
