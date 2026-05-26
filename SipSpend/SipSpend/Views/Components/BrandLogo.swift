import SwiftUI

struct BrandLogo: View {
    var size: CGFloat = 44
    var showTitle: Bool = true

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [DS.Colors.accent, DS.Colors.accent.opacity(0.55)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size, height: size)
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: size * 0.42, weight: .semibold))
                    .foregroundStyle(.white)
                    .symbolRenderingMode(.palette)
            }
            .shadow(color: DS.Colors.accent.opacity(0.35), radius: 8, y: 4)

            if showTitle {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.appName)
                        .font(.title2.bold())
                    Text("€ · ml")
                        .font(.caption)
                        .foregroundStyle(DS.Colors.muted)
                }
            }
        }
    }
}

#Preview {
    BrandLogo()
        .padding()
}
