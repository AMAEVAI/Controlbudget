import Foundation

enum MoneyFormat {
    static let eur: Decimal.FormatStyle.Currency = .currency(code: "EUR")
}

extension Decimal {
    var eurString: String {
        formatted(MoneyFormat.eur)
    }

    var expenseDisplay: String {
        abs(self).eurString
    }
}

extension Int {
    var mlString: String {
        "\(self) ml"
    }
}
