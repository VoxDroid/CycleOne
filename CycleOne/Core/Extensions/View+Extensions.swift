//
//  View+Extensions.swift
//  CycleOne
//

import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(Theme.cornerRadius)
    }

    func sectionHeaderStyle() -> some View {
        self
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
            .textCase(.uppercase)
    }

    func premiumCard() -> some View {
        self
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Theme.cornerRadius)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(
                        color: Color.themeAccent.opacity(0.08),
                        radius: Theme.shadowRadius,
                        x: 0, y: 4
                    )
            )
    }

    func fadeSlideIn(delay: Double = 0) -> some View {
        modifier(FadeSlideModifier(delay: delay))
    }

    func gentlePulse() -> some View {
        modifier(GentlePulseModifier())
    }
}

struct FadeSlideModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 12)
            .onAppear {
                withAnimation(
                    .spring(response: 0.5, dampingFraction: 0.8)
                        .delay(delay)
                ) {
                    isVisible = true
                }
            }
    }
}

struct GentlePulseModifier: ViewModifier {
    @State private var isPulsing = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPulsing ? 1.03 : 1.0)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                ) {
                    isPulsing = true
                }
            }
    }
}
