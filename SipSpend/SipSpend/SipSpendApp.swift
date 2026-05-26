import SwiftUI
import SwiftData

@main
struct SipSpendApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: [Account.self, Category.self, Transaction.self])
    }
}
