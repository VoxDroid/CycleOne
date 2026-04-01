//
//  HelpView.swift
//  CycleOne
//

import SwiftUI

struct HelpView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    var body: some View {
        List {
            Section("User Guide") {
                GuideCard(
                    icon: "calendar",
                    title: "Calendar",
                    description: "The main screen shows your cycle. " +
                        "Tap any date to view details or log data.",
                    color: .themeAccent
                )
                GuideCard(
                    icon: "pencil.and.outline",
                    title: "Logging",
                    description: "Log your flow, symptoms, mood, and " +
                        "energy. Auto-saved when you navigate away.",
                    color: .themeFertile
                )
                GuideCard(
                    icon: "chart.bar.fill",
                    title: "Insights",
                    description: "View your average cycle length, " +
                        "period duration, and top symptoms.",
                    color: .green
                )
                GuideCard(
                    icon: "bell.fill",
                    title: "Reminders",
                    description: "Enable notifications in Settings " +
                        "for alerts before period or fertile window.",
                    color: .orange
                )
            }

            Section("Quick Tips") {
                NumberedTip(
                    number: 1,
                    text: "Swipe left or right to change months."
                )
                NumberedTip(
                    number: 2,
                    text: "Tap the detail card to log or edit."
                )
                NumberedTip(
                    number: 3,
                    text: "Check Insights to understand patterns."
                )
                NumberedTip(
                    number: 4,
                    text: "Export your data anytime — you own it."
                )
            }

            Section("App Philosophy") {
                VStack(alignment: .leading, spacing: 14) {
                    PhilosophyItem(
                        icon: "lock.shield.fill",
                        title: "Privacy First",
                        description: "Zero cloud sync and zero " +
                            "tracking. Data stays on your device.",
                        color: .green
                    )
                    Divider()
                    PhilosophyItem(
                        icon: "heart.fill",
                        title: "No Subscriptions",
                        description: "Don't pay monthly for your " +
                            "own health data. One purchase, forever.",
                        color: .themeAccent
                    )
                }
                .padding(.vertical, 6)
            }

            Section("Manual & Support") {
                if let url = URL(
                    string: "https://github.com/VoxDroid/CycleOne"
                ) {
                    Link(destination: url) {
                        Label(
                            "View Project on GitHub",
                            systemImage: "link"
                        )
                    }
                }

                NavigationLink(destination: PrivacyPolicyView()) {
                    Label("Privacy Policy", systemImage: "shield.fill")
                }
            }
        }
        .accessibilityIdentifier("HelpViewRoot")
        .navigationTitle("Help & Guide")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct GuideCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background(color)
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct NumberedTip: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 22, height: 22)
                .background(Color.themeAccent)
                .clipShape(Circle())

            Text(text)
                .font(.subheadline)
        }
        .padding(.vertical, 2)
    }
}

private struct PhilosophyItem: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HelpView()
    }
}
