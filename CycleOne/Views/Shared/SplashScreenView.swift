//
//  SplashScreenView.swift
//  CycleOne
//

import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let onFinish: () -> Void

    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20
    @State private var titleOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var isExiting = false

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Image("AppLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(
                        color: Color.themeAccent.opacity(0.15),
                        radius: 16, x: 0, y: 8
                    )
                    .scaleEffect(isExiting ? 1.1 : logoScale)
                    .opacity(isExiting ? 0 : logoOpacity)

                VStack(spacing: 8) {
                    Text("CycleOne")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.themeAccent)
                        .offset(y: isExiting ? -10 : titleOffset)
                        .opacity(isExiting ? 0 : titleOpacity)

                    Text("Privacy-first period tracking")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .opacity(isExiting ? 0 : taglineOpacity)
                }

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            // Logo entrance
            withAnimation(
                .spring(response: 0.8, dampingFraction: 0.6)
                    .delay(0.2)
            ) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            // Title slide up
            withAnimation(
                .spring(response: 0.6, dampingFraction: 0.8)
                    .delay(0.5)
            ) {
                titleOffset = 0
                titleOpacity = 1.0
            }

            // Tagline fade in
            withAnimation(.easeOut(duration: 0.5).delay(0.8)) {
                taglineOpacity = 1.0
            }

            // Exit animation + dismiss
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    isExiting = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onFinish()
                }
            }
        }
    }
}

#Preview {
    SplashScreenView(onFinish: {})
}
