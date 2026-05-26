import SwiftUI

struct OnboardingView: View {
    let onFinish: () -> Void

    @State private var page = 0
    @State private var heroAppeared = false

    private struct OnboardingPage {
        let icon: String
        let title: String
        let body: String
        let highlights: [String]
        let tint: Color
    }

    private var pages: [OnboardingPage] {
        [
            OnboardingPage(
                icon: "eurosign.circle.fill",
                title: L10n.onboarding1Title,
                body: L10n.onboarding1Body,
                highlights: ["€", L10n.budgets, L10n.monthlyLimit],
                tint: Color(red: 0.18, green: 0.45, blue: 0.95)
            ),
            OnboardingPage(
                icon: "cup.and.saucer.fill",
                title: L10n.onboarding2Title,
                body: L10n.onboarding2Body,
                highlights: ["ml", L10n.drinks, L10n.volume],
                tint: Color(red: 0.12, green: 0.62, blue: 0.58)
            ),
            OnboardingPage(
                icon: "bell.badge.fill",
                title: L10n.onboarding3Title,
                body: L10n.onboarding3Body,
                highlights: ["80%", "100%", L10n.budgets],
                tint: Color(red: 0.55, green: 0.32, blue: 0.92)
            ),
        ]
    }

    var body: some View {
        ZStack {
            onboardingBackground(tint: pages[page].tint)

            VStack(spacing: 0) {
                header
                    .padding(.top, DS.Spacing.lg)
                    .padding(.horizontal, DS.Spacing.lg)

                TabView(selection: $page) {
                    ForEach(pages.indices, id: \.self) { index in
                        pageCard(pages[index])
                            .tag(index)
                            .padding(.horizontal, DS.Spacing.lg)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(DS.Motion.spring, value: page)
                .onChange(of: page) { _, _ in
                    heroAppeared = false
                    withAnimation(DS.Motion.spring) {
                        heroAppeared = true
                    }
                }

                pageIndicator
                    .padding(.top, DS.Spacing.md)

                ctaButton
                    .padding(.horizontal, DS.Spacing.lg)
                    .padding(.top, DS.Spacing.lg)
                    .padding(.bottom, DS.Spacing.lg)
            }
        }
        .onAppear {
            withAnimation(DS.Motion.spring.delay(0.15)) {
                heroAppeared = true
            }
        }
    }

    private var header: some View {
        BrandLogo(size: 52, showTitle: true)
            .frame(maxWidth: .infinity)
    }

    private func pageCard(_ item: OnboardingPage) -> some View {
        VStack(spacing: DS.Spacing.lg) {
            Spacer(minLength: DS.Spacing.sm)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [item.tint.opacity(0.35), item.tint.opacity(0.05)],
                            center: .center,
                            startRadius: 8,
                            endRadius: 110
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 2)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [item.tint, item.tint.opacity(0.65)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 108, height: 108)
                    .shadow(color: item.tint.opacity(0.45), radius: 20, y: 10)

                Image(systemName: item.icon)
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(.white)
                    .symbolRenderingMode(.hierarchical)
            }
            .scaleEffect(heroAppeared ? 1 : 0.88)
            .opacity(heroAppeared ? 1 : 0)

            VStack(spacing: DS.Spacing.md) {
                Text(item.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)

                Text(item.body)
                    .font(.body)
                    .foregroundStyle(DS.Colors.muted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, DS.Spacing.sm)
            .offset(y: heroAppeared ? 0 : 12)
            .opacity(heroAppeared ? 1 : 0)

            HStack(spacing: DS.Spacing.sm) {
                ForEach(item.highlights, id: \.self) { label in
                    Text(label)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, DS.Spacing.md)
                        .padding(.vertical, DS.Spacing.xs)
                        .background(item.tint.opacity(0.14), in: Capsule())
                        .foregroundStyle(item.tint)
                }
            }
            .offset(y: heroAppeared ? 0 : 8)
            .opacity(heroAppeared ? 1 : 0)

            Spacer(minLength: DS.Spacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(DS.Spacing.lg)
        .background {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    item.tint.opacity(0.45),
                                    item.tint.opacity(0.08),
                                    .white.opacity(0.25),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: item.tint.opacity(0.18), radius: 24, y: 12)
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages.indices, id: \.self) { index in
                Capsule()
                    .fill(index == page ? pages[page].tint : Color.secondary.opacity(0.25))
                    .frame(width: index == page ? 28 : 8, height: 8)
                    .animation(DS.Motion.spring, value: page)
            }
        }
    }

    private var ctaButton: some View {
        Button {
            if page < pages.count - 1 {
                withAnimation(DS.Motion.spring) { page += 1 }
            } else {
                onFinish()
            }
        } label: {
            HStack(spacing: DS.Spacing.sm) {
                Text(page < pages.count - 1 ? L10n.onboardingNext : L10n.onboardingStart)
                Image(systemName: page < pages.count - 1 ? "arrow.right" : "checkmark")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [pages[page].tint, pages[page].tint.opacity(0.75)],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: DS.Radius.pill + 4, style: .continuous)
            )
            .foregroundStyle(.white)
            .shadow(color: pages[page].tint.opacity(0.4), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func onboardingBackground(tint: Color) -> some View {
        ZStack {
            LinearGradient(
                colors: [
                    tint.opacity(0.22),
                    Color(uiColor: .systemBackground),
                    Color(uiColor: .systemGroupedBackground),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(tint.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 40)
                .offset(x: -120, y: -180)

            Circle()
                .fill(DS.Colors.accent.opacity(0.08))
                .frame(width: 260, height: 260)
                .blur(radius: 36)
                .offset(x: 140, y: 120)

            Circle()
                .stroke(tint.opacity(0.15), lineWidth: 1)
                .frame(width: 420, height: 420)
                .offset(y: -60)
        }
        .animation(DS.Motion.spring, value: page)
    }
}

#Preview {
    OnboardingView(onFinish: {})
}
