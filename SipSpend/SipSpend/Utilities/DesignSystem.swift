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
}
