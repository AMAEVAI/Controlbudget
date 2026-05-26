import Foundation

enum CSVExportService {
    static func makeCSV(transactions: [Transaction]) -> String {
        var lines = ["date,category,amount_eur,note,volume_ml"]
        let formatter = ISO8601DateFormatter()

        for tx in transactions.sorted(by: { $0.date > $1.date }) {
            let date = formatter.string(from: tx.date)
            let category = (tx.category?.name ?? L10n.uncategorized)
                .replacingOccurrences(of: ",", with: " ")
            let amount = "\(tx.amount)"
            let note = (tx.note ?? "").replacingOccurrences(of: ",", with: " ")
            let ml = tx.volumeML.map(String.init) ?? ""
            lines.append("\(date),\(category),\(amount),\(note),\(ml)")
        }

        return lines.joined(separator: "\n")
    }

    static func temporaryFileURL(csv: String) -> URL? {
        let name = "sipspend-export-\(Int(Date().timeIntervalSince1970)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        do {
            try csv.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }
}
