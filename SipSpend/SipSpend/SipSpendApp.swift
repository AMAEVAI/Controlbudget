import SwiftUI
import SwiftData

@main
struct SipSpendApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
        .modelContainer(for: [Account.self, Category.self, Transaction.self])
    }
}
