import Foundation
import SwiftData

@Model
final class Account {
    var name: String
    var balance: Decimal

    init(name: String = "Main", balance: Decimal = 0) {
        self.name = name
        self.balance = balance
    }
}
