//
//  SettingsView.swift
//  CycleOne
//

import CoreData
import OSLog
import SwiftUI

struct SettingsView: View {
    @Environment(\.managedObjectContext) var context
    @AppStorage("enablePredictions") private var enablePredictions = true
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            List {
                // App icon header
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 10) {
                            Image("AppLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 72, height: 72)
                                .clipShape(
                                    RoundedRectangle(
                                        cornerRadius: 16
                                    )
                                )
                                .shadow(
                                    color: Color.themeAccent
                                        .opacity(0.15),
                                    radius: 8, x: 0, y: 4
                                )

                            Text("CycleOne")
                                .font(.system(
                                    .title3,
                                    design: .rounded
                                ))
                                .fontWeight(.bold)
                                .foregroundColor(.themeAccent)

                            Text("Version 1.0.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }

                Section("Preferences") {
                    Toggle(isOn: $enablePredictions) {
                        SettingsRow(
                            icon: "wand.and.stars",
                            title: "Enable Predictions",
                            color: .themeFertile
                        )
                    }

                    NavigationLink(
                        destination: NotificationSettingsView()
                    ) {
                        SettingsRow(
                            icon: "bell.fill",
                            title: "Notifications",
                            color: .orange
                        )
                    }
                }

                Section("Appearance") {
                    HStack {
                        SettingsRow(
                            icon: "paintbrush.fill",
                            title: "Theme",
                            color: .themeAccent
                        )
                        Spacer()
                        Picker(
                            "",
                            selection: $themeManager.selectedTheme
                        ) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(theme.rawValue).tag(theme)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Accent Color")
                            .font(.subheadline)
                            .accessibilityIdentifier("AccentColorTitle")

                        HStack(spacing: 12) {
                            ForEach(AccentTheme.allCases) { accent in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        themeManager.selectedAccent = accent
                                    }
                                }, label: {
                                    VStack(spacing: 4) {
                                        Circle()
                                            .fill(accent.accentColor)
                                            .frame(width: 32, height: 32)
                                            .overlay(
                                                Circle()
                                                    .stroke(
                                                        Color.primary,
                                                        lineWidth: themeManager
                                                            .selectedAccent == accent ? 2 : 0
                                                    )
                                                    .padding(
                                                        themeManager
                                                            .selectedAccent == accent ? -3 : 0
                                                    )
                                            )
                                        Text(accent.rawValue)
                                            .font(.caption2)
                                            .foregroundColor(
                                                themeManager
                                                    .selectedAccent == accent ?
                                                    .primary : .secondary
                                            )
                                    }
                                })
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("Data") {
                    NavigationLink(destination: ExportView()) {
                        SettingsRow(
                            icon: "square.and.arrow.up",
                            title: "Export Data (CSV)",
                            color: .green
                        )
                    }

                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        SettingsRow(
                            icon: "trash",
                            title: "Delete All Data",
                            color: .red
                        )
                    }
                }

                Section("App") {
                    NavigationLink(destination: HelpView()) {
                        SettingsRow(
                            icon: "questionmark.circle.fill",
                            title: "Help & Guide",
                            color: .blue
                        )
                    }

                    if let url = URL(
                        string: "https://github.com/VoxDroid/CycleOne"
                    ) {
                        Link(destination: url) {
                            SettingsRow(
                                icon: "link",
                                title: "Support & Feedback",
                                color: .teal
                            )
                        }
                    }

                    NavigationLink(
                        destination: PrivacyPolicyView()
                    ) {
                        SettingsRow(
                            icon: "shield.fill",
                            title: "Privacy Policy",
                            color: .indigo
                        )
                    }

                    if let url = URL(
                        string: "https://apps.apple.com/app/id6742514330?action=write-review"
                    ) {
                        Link(destination: url) {
                            SettingsRow(
                                icon: "star.fill",
                                title: "Rate CycleOne",
                                color: .yellow
                            )
                        }
                    }

                    NavigationLink(
                        destination: AboutView()
                            .environmentObject(
                                themeManager
                            )
                    ) {
                        SettingsRow(
                            icon: "info.circle.fill",
                            title: "About",
                            color: .gray
                        )
                    }
                }

                Section {
                    VStack(spacing: 4) {
                        Text("CycleOne by VoxDroid")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Text(
                            "\u{00A9} 2026 VoxDroid. " +
                                "All rights reserved."
                        )
                        .font(.caption2)
                        .foregroundColor(
                            .secondary.opacity(0.7)
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
                }
            }
            .accessibilityIdentifier("SettingsList")
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .alert(
                "Delete All Data?",
                isPresented: $showingDeleteAlert
            ) {
                Button("Delete", role: .destructive) {
                    deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(
                    "This action cannot be undone. All your " +
                        "logged cycles and symptoms will be " +
                        "permanently removed."
                )
            }
        }
    }

    private func deleteAllData() {
        let entities = ["Cycle", "DayLog", "Symptom"]
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(
                entityName: entity
            )
            let deleteRequest = NSBatchDeleteRequest(
                fetchRequest: fetchRequest
            )
            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                Logger.storage.error(
                    "Failed to delete \(entity): \(error.localizedDescription)"
                )
            }
        }
        PersistenceController.shared.container.viewContext.reset()
    }
}
