//
//  SplashScreenView.swift
//  CycleOne
//

import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let onFinish: () -> Void

    @State private var logoScale: CGFloat
    @State private var logoOpacity: Double
    @State private var titleOffset: CGFloat
    @State private var titleOpacity: Double
    @State private var taglineOpacity: Double
    @State private var isExiting: Bool
    @State private var floatOffset: CGFloat
    @State private var ringScale: CGFloat
    @State private var ringOpacity: Double
    @State private var exitOffset: CGFloat

    init(onFinish: @escaping () -> Void) {
        self.onFinish = onFinish
        _logoScale = State(initialValue: 0.5)
        _logoOpacity = State(initialValue: 0)
        _titleOffset = State(initialValue: 20)
        _titleOpacity = State(initialValue: 0)
        _taglineOpacity = State(initialValue: 0)
        _isExiting = State(initialValue: false)
        _floatOffset = State(initialValue: 0)
        _ringScale = State(initialValue: 0.8)
        _ringOpacity = State(initialValue: 0)
        _exitOffset = State(initialValue: 0)
    }

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            // Ring burst effect (on exit)
            Circle()
                .stroke(
                    Color.themeAccent.opacity(0.3),
                    lineWidth: 3
                )
                .frame(width: 160, height: 160)
                .scaleEffect(ringScale)
                .opacity(ringOpacity)

            VStack(spacing: 24) {
                Spacer()

                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 28)
                    )
                    .shadow(
                        color: Color.themeAccent
                            .opacity(0.2),
                        radius: 20, x: 0, y: 10
                    )
                    .scaleEffect(
                        isExiting ? 0.6 : logoScale
                    )
                    .opacity(isExiting ? 0 : logoOpacity)
                    .offset(
                        y: isExiting
                            ? exitOffset
                            : floatOffset
                    )

                VStack(spacing: 8) {
                    Text("CycleOne")
                        .font(.system(
                            size: 32, weight: .bold,
                            design: .rounded
                        ))
                        .foregroundColor(.themeAccent)
                        .offset(
                            y: isExiting
                                ? exitOffset * 0.5
                                : titleOffset
                        )
                        .opacity(
                            isExiting ? 0 : titleOpacity
                        )

                    Text("Privacy-first period tracking")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .opacity(
                            isExiting ? 0 : taglineOpacity
                        )
                }

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            // Logo entrance: spring bounce in
            withAnimation(
                .spring(response: 0.8, dampingFraction: 0.6)
                    .delay(0.2)
            ) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            // Title slide up
            withAnimation(
                .spring(
                    response: 0.6,
                    dampingFraction: 0.8
                )
                .delay(0.5)
            ) {
                titleOffset = 0
                titleOpacity = 1.0
            }

            // Tagline fade in
            withAnimation(
                .easeOut(duration: 0.5).delay(0.8)
            ) {
                taglineOpacity = 1.0
            }

            // Floating hover animation (continuous)
            withAnimation(
                .easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true)
                    .delay(1.0)
            ) {
                floatOffset = -8
            }

            // Exit sequence
            DispatchQueue.main.asyncAfter(
                deadline: .now() + 2.2
            ) {
                // Ring burst
                withAnimation(
                    .easeOut(duration: 0.5)
                ) {
                    ringScale = 3.0
                    ringOpacity = 0.6
                }
                withAnimation(
                    .easeOut(duration: 0.3).delay(0.2)
                ) {
                    ringOpacity = 0
                }

                // Fly off and shrink
                withAnimation(
                    .easeIn(duration: 0.5)
                ) {
                    isExiting = true
                    exitOffset = -200
                }

                DispatchQueue.main.asyncAfter(
                    deadline: .now() + 0.5
                ) {
                    onFinish()
                }
            }
        }
    }
}

#Preview {
    SplashScreenView(onFinish: {})
}
