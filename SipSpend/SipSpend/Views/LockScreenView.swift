import SwiftUI

struct LockScreenView: View {
    let onUnlocked: () -> Void

    @State private var message = ""

    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            BrandLogo(size: 64)
            Text(L10n.appName)
                .font(.title.bold())
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button {
                Task {
                    let ok = await AppLockManager.authenticate(reason: L10n.appName)
                    if ok {
                        onUnlocked()
                    } else {
                        message = String(localized: "lock.failed", defaultValue: "Authentication failed")
                    }
                }
            } label: {
                Label(L10n.unlock, systemImage: "faceid")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, DS.Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(uiColor: .systemBackground))
        .task {
            let ok = await AppLockManager.authenticate(reason: L10n.appName)
            if ok { onUnlocked() }
        }
    }
}
