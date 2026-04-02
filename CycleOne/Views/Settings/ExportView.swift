//
//  ExportView.swift
//  CycleOne
//

import SwiftUI

struct ExportView: View {
    @Environment(\.managedObjectContext) var context
    @State private var exportURL: URL?
    @State private var isGenerating = false

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "doc.text.below.ecg.fill")
                .font(.system(size: 64))
                .foregroundColor(.themeAccent)
                .padding(.top, 40)

            VStack(spacing: 8) {
                Text("Export Your Data")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Get a CSV file of all your logged cycles and symptoms. Your data stays private.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            if isGenerating {
                ProgressView("Generating CSV...")
                    .accessibilityIdentifier("Export_GeneratingProgress")
            } else if let url = exportURL {
                ShareLink(item: url) {
                    Label("Share CSV File", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.themeAccent)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .accessibilityIdentifier("Export_ShareLink")
                .padding(.horizontal)

                Button("Regenerate") {
                    generateExport()
                }
                .accessibilityIdentifier("Export_RegenerateButton")
                .foregroundColor(.themeAccent)
            } else {
                Button(action: generateExport) {
                    Text("Generate CSV")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.themeAccent)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .accessibilityIdentifier("Export_GenerateButton")
                .padding(.horizontal)
            }

            Text("Export is plaintext only. No proprietary format.")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 20)
        }
        .accessibilityIdentifier("ExportViewRoot")
        .navigationTitle("Export")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func generateExport() {
        isGenerating = true
        DispatchQueue.global(qos: .userInitiated).async {
            let url = ExportService.shared.generateCSV(context: context)
            DispatchQueue.main.async {
                self.exportURL = url
                self.isGenerating = false
            }
        }
    }
}
