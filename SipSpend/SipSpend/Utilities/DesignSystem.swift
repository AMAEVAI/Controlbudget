import SwiftUI

enum DS {
    enum Spacing {
        static let xs: CGFloat = 6
        static let sm: CGFloat = 10
        static let md: CGFloat = 14
        static let lg: CGFloat = 20
    }

    enum Radius {
        static let card: CGFloat = 18
        static let pill: CGFloat = 12
    }

    enum Colors {
        static let accent = Color.accentColor
        static let card = Color(uiColor: .secondarySystemBackground)
        static let cardAlt = Color(uiColor: .tertiarySystemBackground)
        static let success = Color.green
        static let warning = Color.orange
        static let danger = Color.red
        static let muted = Color.secondary
    }

    /// Extra space so the last row clears the floating tab bar when scrolling.
    enum Layout {
        static let tabBarScrollPadding: CGFloat = 96
    }

    enum Motion {
        static let spring = Animation.spring(response: 0.45, dampingFraction: 0.82)
        static let chartSpring = Animation.spring(response: 0.85, dampingFraction: 0.78)
        static let staggerStep: Double = 0.07
    }
}

extension View {
    func cardStyle(padding: CGFloat = DS.Spacing.md) -> some View {
        self
            .padding(padding)
            .background(DS.Colors.card, in: RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous)
                    .stroke(.quaternary, lineWidth: 1)
            )
    }

    func subtleCardStyle(padding: CGFloat = DS.Spacing.md) -> some View {
        self
            .padding(padding)
            .background(DS.Colors.cardAlt, in: RoundedRectangle(cornerRadius: DS.Radius.card, style: .continuous))
    }

    func tabBarScrollPadding() -> some View {
        padding(.bottom, DS.Layout.tabBarScrollPadding)
    }

    func staggeredCardAppear(index: Int, appeared: Bool) -> some View {
        opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 18)
            .scaleEffect(appeared ? 1 : 0.97)
            .animation(
                .spring(response: 0.5, dampingFraction: 0.82)
                    .delay(Double(index) * DS.Motion.staggerStep),
                value: appeared
            )
    }
}
