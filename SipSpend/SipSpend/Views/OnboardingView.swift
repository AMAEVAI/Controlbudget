import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var page = 0

    private let pages: [(icon: String, title: String, body: String)] = [
        ("eurosign.circle.fill", L10n.onboarding1Title, L10n.onboarding1Body),
        ("cup.and.saucer.fill", L10n.onboarding2Title, L10n.onboarding2Body),
        ("bell.badge.fill", L10n.onboarding3Title, L10n.onboarding3Body),
    ]

    var body: some View {
        VStack(spacing: DS.Spacing.lg) {
            Spacer()
            BrandLogo(size: 56)

            TabView(selection: $page) {
                ForEach(pages.indices, id: \.self) { index in
                    VStack(spacing: DS.Spacing.md) {
                        Image(systemName: pages[index].icon)
                            .font(.system(size: 56))
                            .foregroundStyle(DS.Colors.accent)
                            .symbolRenderingMode(.hierarchical)
                        Text(pages[index].title)
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                        Text(pages[index].body)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 280)

            Button {
                if page < pages.count - 1 {
                    withAnimation(DS.Motion.spring) { page += 1 }
                } else {
                    onFinish()
                }
            } label: {
                Text(page < pages.count - 1 ? L10n.onboardingNext : L10n.onboardingStart)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(DS.Colors.accent, in: RoundedRectangle(cornerRadius: DS.Radius.pill, style: .continuous))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.bottom, DS.Spacing.lg)
        }
        .background(
            LinearGradient(
                colors: [DS.Colors.accent.opacity(0.12), Color(uiColor: .systemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
