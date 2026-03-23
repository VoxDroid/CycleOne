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
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section("Preferences") {
                    Toggle("Enable Predictions", isOn: $enablePredictions)

                    NavigationLink(destination: NotificationSettingsView()) {
                        Label("Notifications", systemImage: "bell.fill")
                    }
                }

                Section("Data") {
                    NavigationLink(destination: ExportView()) {
                        Label("Export Data (CSV)", systemImage: "square.and.arrow.up")
                    }

                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Delete All Data", systemImage: "trash")
                    }
                }

                Section("App") {
                    if let url = URL(string: "https://github.com/VoxDroid/CycleOne") {
                        Link(destination: url) {
                            Label("Support & Feedback", systemImage: "link")
                        }
                    }

                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("Privacy Policy", systemImage: "shield.fill")
                    }

                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Delete All Data?", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    deleteAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This action cannot be undone. All your logged cycles and symptoms will be permanently removed.")
            }
        }
    }

    private func deleteAllData() {
        let entities = ["Cycle", "DayLog", "Symptom"]
        for entity in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                Logger.storage.error("Failed to delete \(entity): \(error.localizedDescription)")
            }
        }
        // Force refresh
        PersistenceController.shared.container.viewContext.reset()
    }
}
