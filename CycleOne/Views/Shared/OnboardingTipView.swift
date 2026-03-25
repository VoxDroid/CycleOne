//
//  OnboardingTipView.swift
//  CycleOne
//

import SwiftUI

struct OnboardingTipView: View {
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Welcome to CycleOne")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("A privacy-first period tracker.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 16) {
                    TipRow(icon: "calendar.badge.plus", text: "Tap any day to log your period, symptoms, or mood.")
                    TipRow(icon: "arrow.left.and.right", text: "Swipe the calendar to navigate between months.")
                    TipRow(
                        icon: "info.circle",
                        text: "Check the top banner for your next period and ovulation predictions."
                    )
                }

                Button(action: onDismiss) {
                    Text("Got it!")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.themeAccent)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 8)
            }
            .padding(32)
            .background(Color(.systemBackground))
            .cornerRadius(24)
            .shadow(radius: 20)
            .padding(.horizontal, 24)
        }
    }
}

struct TipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.themeAccent)
                .frame(width: 32)
            Text(text)
                .font(.callout)
        }
    }
}

#Preview {
    OnboardingTipView(onDismiss: {})
}
