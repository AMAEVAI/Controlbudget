#if canImport(UIKit)
import UIKit

enum Haptics {
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func lightTap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
}
#else
enum Haptics {
    static func success() {}
    static func lightTap() {}
}
#endif
