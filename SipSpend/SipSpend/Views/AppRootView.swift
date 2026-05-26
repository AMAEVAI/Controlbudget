import SwiftUI
import SwiftData

struct AppRootView: View {
    @AppStorage(AppPreferences.hasSeenOnboarding) private var hasSeenOnboarding = false
    @AppStorage(AppPreferences.biometricLockEnabled) private var biometricLockEnabled = false
    @AppStorage(AppPreferences.appearanceMode) private var appearanceModeRaw = AppearanceMode.system.rawValue

    @State private var isUnlocked = false

    private var colorScheme: ColorScheme? {
        switch AppearanceMode(rawValue: appearanceModeRaw) ?? .system {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var body: some View {
        Group {
            if !hasSeenOnboarding {
                OnboardingView {
                    hasSeenOnboarding = true
                }
            } else if biometricLockEnabled && !isUnlocked {
                LockScreenView {
                    isUnlocked = true
                }
            } else {
                RootTabView()
            }
        }
        .preferredColorScheme(colorScheme)
    }
}

#Preview {
    AppRootView()
        .modelContainer(for: [Account.self, Category.self, Transaction.self], inMemory: true)
}
