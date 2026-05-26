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
                                .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: delete)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        Color.clear.frame(height: DS.Layout.tabBarScrollPadding)
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
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
        HStack(spacing: DS.Spacing.md) {
            Circle()
                .fill(transaction.amount < 0 ? Color.red.opacity(0.12) : Color.green.opacity(0.12))
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: transaction.amount < 0 ? "arrow.down" : "arrow.up")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(transaction.amount < 0 ? .red : .green)
                }

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
        .cardStyle()
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ActivityView()
        .modelContainer(for: [Account.self, Category.self, Transaction.self], inMemory: true)
}
