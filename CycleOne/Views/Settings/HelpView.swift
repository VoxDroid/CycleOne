//
//  HelpView.swift
//  CycleOne
//

import SwiftUI

struct HelpView: View {
    var body: some View {
        List {
            Section("User Guide") {
                GuideRow(
                    icon: "calendar",
                    title: "Calendar",
                    description: "The main screen shows your cycle at a glance. Tap any date to view details or log data."
                )
                GuideRow(
                    icon: "pencil.and.outline",
                    title: "Logging",
                    description: "Log your flow, symptoms, mood, and energy. Data is auto-saved when you navigate away."
                )
                GuideRow(
                    icon: "chart.bar.fill",
                    title: "Insights",
                    description: "View your average cycle length, period duration, and top symptoms over time."
                )
                GuideRow(
                    icon: "bell.fill",
                    title: "Reminders",
                    description: "Enable notifications in Settings to get alerts before your next period or fertile window."
                )
            }

            Section("Navigation Tips") {
                TipItem(text: "Swipe left or right on the calendar to change months.")
                TipItem(text: "Tap the 'Today' button in the calendar header to quickly return to current date.")
                TipItem(text: "Tap a cycle in the Insights history to see its full breakdown.")
            }

            Section("App Philosophy") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Privacy First")
                        .font(.headline)
                    Text(
                        "CycleOne is designed with zero cloud sync and zero tracking. Your data is stored exclusively on your device in a secure local database."
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    Divider()

                    Text("No Subscriptions")
                        .font(.headline)
                    Text("We believe you shouldn't pay monthly to access your own health data. " +
                        "One purchase, forever yours.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 8)
            }

            Section("Manual & Support") {
                Link(destination: URL(string: "https://github.com/VoxDroid/CycleOne")!) {
                    Label("View Project on GitHub", systemImage: "link")
                }

                NavigationLink(destination: PrivacyPolicyView()) {
                    Label("Privacy Policy", systemImage: "shield.fill")
                }
            }
        }
        .navigationTitle("Help & Guide")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GuideRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.themeAccent)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct TipItem: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
                .font(.caption)
                .padding(.top, 2)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    NavigationStack {
        HelpView()
    }
}
