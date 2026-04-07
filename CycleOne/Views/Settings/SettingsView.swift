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
    @AppStorage(AppLanguage.storageKey) private var selectedLanguageCode = AppLanguage.system.rawValue
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

                Section("settings.section.preferences") {
                    Toggle(isOn: $enablePredictions) {
                        SettingsRow(
                            icon: "wand.and.stars",
                            title: "settings.enable_predictions",
                            color: .themeFertile
                        )
                    }
                    .accessibilityIdentifier("Settings_EnablePredictionsToggle")

                    NavigationLink(
                        destination: NotificationSettingsView()
                    ) {
                        SettingsRow(
                            icon: "bell.fill",
                            title: "settings.notifications",
                            color: .orange
                        )
                    }
                    .accessibilityIdentifier("Settings_NotificationsLink")
                }

                Section("settings.section.appearance") {
                    HStack {
                        SettingsRow(
                            icon: "paintbrush.fill",
                            title: "settings.theme",
                            color: .themeAccent
                        )
                        Spacer()
                        Picker(
                            "",
                            selection: $themeManager.selectedTheme
                        ) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(theme.displayNameKey).tag(theme)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }

                    HStack {
                        SettingsRow(
                            icon: "globe",
                            title: "settings.language",
                            color: .blue
                        )
                        Spacer()
                        Picker(
                            "",
                            selection: $selectedLanguageCode
                        ) {
                            ForEach(AppLanguage.allCases) { language in
                                Text(language.displayNameKey).tag(language.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .accessibilityIdentifier("Settings_LanguagePicker")
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("settings.accent_color")
                            .font(.subheadline)
                            .accessibilityIdentifier("AccentColorTitle")

                        HStack(spacing: 12) {
                            ForEach(AccentTheme.allCases) { accent in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        SettingsView.applyAccent(
                                            accent,
                                            themeManager: themeManager
                                        )
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
                                        Text(accent.displayNameKey)
                                            .font(.caption2)
                                            .foregroundColor(
                                                themeManager
                                                    .selectedAccent == accent ?
                                                    .primary : .secondary
                                            )
                                    }
                                })
                                .buttonStyle(.plain)
                                .accessibilityIdentifier("Settings_Accent_\(accent.rawValue)")
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section("settings.section.data") {
                    NavigationLink(destination: ExportView()) {
                        SettingsRow(
                            icon: "square.and.arrow.up",
                            title: "settings.export_csv",
                            color: .green
                        )
                    }
                    .accessibilityIdentifier("Settings_ExportLink")

                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        SettingsRow(
                            icon: "trash",
                            title: "settings.delete_all_data",
                            color: .red
                        )
                    }
                    .accessibilityIdentifier("Settings_DeleteAllDataButton")
                }

                Section("settings.section.app") {
                    NavigationLink(destination: HelpView()) {
                        SettingsRow(
                            icon: "questionmark.circle.fill",
                            title: "settings.help_guide",
                            color: .blue
                        )
                    }
                    .accessibilityIdentifier("Settings_HelpLink")

                    if let url = URL(
                        string: "https://github.com/VoxDroid/CycleOne"
                    ) {
                        Link(destination: url) {
                            SettingsRow(
                                icon: "link",
                                title: "settings.support_feedback",
                                color: .teal
                            )
                        }
                    }

                    NavigationLink(
                        destination: PrivacyPolicyView()
                    ) {
                        SettingsRow(
                            icon: "shield.fill",
                            title: "settings.privacy_policy",
                            color: .indigo
                        )
                    }
                    .accessibilityIdentifier("Settings_PrivacyLink")

                    if let url = URL(
                        string: "https://apps.apple.com/app/id6742514330?action=write-review"
                    ) {
                        Link(destination: url) {
                            SettingsRow(
                                icon: "star.fill",
                                title: "settings.rate_cycleone",
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
                            title: "settings.about",
                            color: .gray
                        )
                    }
                    .accessibilityIdentifier("Settings_AboutLink")
                }

                Section {
                    VStack(spacing: 4) {
                        Text("settings.footer.byline")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        Text("settings.footer.copyright")
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
            .navigationTitle("settings.navigation_title")
            .navigationBarTitleDisplayMode(.inline)
            .alert(
                "settings.alert.delete_title",
                isPresented: $showingDeleteAlert
            ) {
                Button("settings.alert.delete_action", role: .destructive) {
                    deleteAllData()
                }
                Button("settings.alert.cancel_action", role: .cancel) {}
            } message: {
                Text("settings.alert.delete_message")
            }
        }
        .id("settings-stack-\(selectedLanguageCode)")
        .environment(
            \.locale,
            AppLanguage.fromStoredValue(selectedLanguageCode).locale
        )
    }

    @MainActor
    static func applyAccent(
        _ accent: AccentTheme,
        themeManager: ThemeManager
    ) {
        themeManager.selectedAccent = accent
    }

    static func deleteAllData(in context: NSManagedObjectContext) {
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

    private func deleteAllData() {
        Self.deleteAllData(in: context)
    }
}
