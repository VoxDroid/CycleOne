//
//  OnboardingTipView.swift
//  CycleOne
//

import SwiftUI

struct OnboardingTipView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let onDismiss: () -> Void
    @State private var currentPage: Int

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "heart.circle.fill",
            title: "Welcome to CycleOne",
            subtitle: "A privacy-first period tracker.\nNo subscriptions. No cloud. No account.",
            color: .themeAccent
        ),
        OnboardingPage(
            icon: "calendar.badge.plus",
            title: "Track Your Cycle",
            subtitle: "Tap any day on the calendar to log your period, symptoms, mood, and energy.",
            color: .themeAccent
        ),
        OnboardingPage(
            icon: "chart.bar.fill",
            title: "Discover Patterns",
            subtitle: "View insights about your cycle length, common symptoms, and predictions.",
            color: .themeFertile
        ),
        OnboardingPage(
            icon: "lock.shield.fill",
            title: "Your Data Stays Private",
            subtitle: "Everything is stored on your device.\nNo servers. No tracking. Ever.",
            color: .green
        ),
    ]

    init(onDismiss: @escaping () -> Void, initialPage: Int = 0) {
        self.onDismiss = onDismiss
        _currentPage = State(initialValue: initialPage)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0 ..< pages.count, id: \.self) { index in
                        onboardingPageView(pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 320)

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0 ..< pages.count, id: \.self) { index in
                        Capsule()
                            .fill(
                                index == currentPage ?
                                    Color.themeAccent :
                                    Color.secondary.opacity(0.3)
                            )
                            .frame(
                                width: index == currentPage ? 24 : 8,
                                height: 8
                            )
                            .animation(
                                .spring(response: 0.3),
                                value: currentPage
                            )
                    }
                }
                .padding(.top, 16)

                Button(action: {
                    if currentPage < pages.count - 1 {
                        withAnimation(
                            .spring(response: 0.4, dampingFraction: 0.8)
                        ) {
                            currentPage += 1
                        }
                    } else {
                        onDismiss()
                    }
                }, label: {
                    Text(
                        currentPage < pages.count - 1 ?
                            "Next" : "Get Started"
                    )
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.themeAccent)
                    .foregroundColor(.white)
                    .cornerRadius(14)
                })
                .padding(.top, 24)
                .padding(.horizontal, 8)

                if currentPage < pages.count - 1 {
                    Button("Skip") {
                        onDismiss()
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 12)
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: .black.opacity(0.15),
                        radius: 30, x: 0, y: 10
                    )
            )
            .padding(.horizontal, 20)
        }
        .accessibilityIdentifier("OnboardingTipView")
    }

    private func onboardingPageView(
        _ page: OnboardingPage
    ) -> some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(page.color.opacity(0.12))
                    .frame(width: 100, height: 100)

                Image(systemName: page.icon)
                    .font(.system(size: 44))
                    .foregroundColor(page.color)
            }

            VStack(spacing: 10) {
                Text(page.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
        }
        .padding(.horizontal, 8)
    }
}

private struct OnboardingPage {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
}

#Preview {
    OnboardingTipView(onDismiss: {})
}
