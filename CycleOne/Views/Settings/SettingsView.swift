//
//  SettingsView.swift
//  CycleOne
//
//  Created by Antigravity on 3/23/26.
//

import CoreData
import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = false
    @State private var showingExportSheet = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Notifications")) {
                    Toggle("Enable Predictions", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { _, enabled in
                            if enabled {
                                NotificationService.shared.requestAuthorization()
                            } else {
                                NotificationService.shared.cancelAll()
                            }
                        }

                    if notificationsEnabled {
                        Text("You will receive alerts for predicted periods and fertile windows.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Section(header: Text("Data Management")) {
                    Button(action: { showingExportSheet = true }, label: {
                        Label("Export Data (CSV)", systemImage: "square.and.arrow.up")
                    })
                }

                Section(header: Text("App Info")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Build 1)")
                            .foregroundColor(.secondary)
                    }

                    if let url = URL(string: "https://github.com/drei/CycleOne") {
                        Link(destination: url) {
                            Label("Support & Feedback", systemImage: "link")
                        }
                    }
                }

                Section {
                    Text("All data is stored locally on your device and is not collected by the developer.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingExportSheet) {
                ExportView()
            }
        }
    }
}

struct ExportView: View {
    @Environment(\.dismiss) var dismiss
    @State private var exportURL: URL?
    @State private var isSharing = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "doc.text.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.themeAccent)

                Text("Export Your Data")
                    .font(.title2.bold())

                Text(
                    "Generate a CSV file of your logged cycles and symptoms. " +
                        "This file is generated locally and never leaves your device unless you share it."
                )
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

                if let url = exportURL {
                    ShareLink(item: url) {
                        Label("Share CSV File", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.themeAccent)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                } else {
                    Button(action: {
                        exportURL = ExportService.shared
                            .generateCSV(context: PersistenceController.shared.container.viewContext)
                    }, label: {
                        Text("Generate CSV")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.themeAccent)
                            .cornerRadius(12)
                    })
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
