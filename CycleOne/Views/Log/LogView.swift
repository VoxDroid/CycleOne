//
//  LogView.swift
//  CycleOne
//

import CoreData
import SwiftUI

struct LogView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: LogViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showDeleteAlert = false

    init(date: Date, context: NSManagedObjectContext) {
        _viewModel = StateObject(
            wrappedValue: LogViewModel(date: date, context: context)
        )
    }

    var body: some View {
        Form {
            // Date header
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.formattedDate)
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("Log your day")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Image(systemName: "calendar.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.themeAccent)
                }
            }
            .listRowBackground(Color.clear)

            Section("Flow") {
                FlowPickerView(selection: $viewModel.flow)
            }
            .fadeSlideIn(delay: 0.05)

            Section("Mood & Energy") {
                HStack {
                    ForEach(Mood.allCases, id: \.self) { mood in
                        VStack(spacing: 4) {
                            Image(systemName: mood.icon)
                                .font(.title2)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(
                                            viewModel.mood == mood ?
                                                Color.themeAccent.opacity(0.2) :
                                                Color.clear
                                        )
                                )
                                .scaleEffect(
                                    viewModel.mood == mood ? 1.1 : 1.0
                                )
                                .animation(
                                    .spring(response: 0.3),
                                    value: viewModel.mood
                                )
                            Text(mood.description)
                                .font(.caption2)
                                .foregroundColor(
                                    viewModel.mood == mood ?
                                        .themeAccent : .secondary
                                )
                        }
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.mood = mood
                            }
                        }
                    }
                }
                .padding(.vertical, 8)

                HStack {
                    ForEach(EnergyLevel.allCases, id: \.self) { energy in
                        VStack(spacing: 4) {
                            Image(systemName: energy.icon)
                                .font(.title2)
                                .padding(12)
                                .background(
                                    Circle()
                                        .fill(
                                            viewModel.energy == energy ?
                                                Color.themeAccent.opacity(0.2) :
                                                Color.clear
                                        )
                                )
                                .scaleEffect(
                                    viewModel.energy == energy ? 1.1 : 1.0
                                )
                                .animation(
                                    .spring(response: 0.3),
                                    value: viewModel.energy
                                )
                            Text(energy.description)
                                .font(.caption2)
                                .foregroundColor(
                                    viewModel.energy == energy ?
                                        .themeAccent : .secondary
                                )
                        }
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.energy = energy
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            .fadeSlideIn(delay: 0.1)

            Section("Pain Level: \(Int(viewModel.painLevel))") {
                HStack(spacing: 8) {
                    Image(systemName: "hand.thumbsup")
                        .foregroundColor(.green)
                        .font(.caption)
                    Slider(
                        value: $viewModel.painLevel,
                        in: 0 ... 10, step: 1
                    )
                    .tint(.themePeriod)
                    Image(systemName: "bolt.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
            .fadeSlideIn(delay: 0.15)

            Section("Symptoms") {
                SymptomGridView(
                    selectedSymptoms: $viewModel.selectedSymptoms,
                    symptoms: SymptomType.defaults
                )
            }
            .fadeSlideIn(delay: 0.2)

            Section {
                ZStack(alignment: .topLeading) {
                    if viewModel.notes.isEmpty {
                        Text("Add notes...")
                            .foregroundColor(.secondary.opacity(0.5))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 8)
                    }

                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 100)
                        .onChange(of: viewModel.notes) { _, newValue in
                            if newValue.count > 500 {
                                viewModel.notes = String(
                                    newValue.prefix(500)
                                )
                            }
                        }
                }
            } header: {
                HStack {
                    Text("Notes")
                    Spacer()
                    Text("\(viewModel.notes.count)/500")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .fadeSlideIn(delay: 0.25)

            // Delete log button
            if viewModel.hasExistingLog {
                Section {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete This Log")
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .fadeSlideIn(delay: 0.3)
            }
        }
        .navigationTitle("Log Day")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Dismiss") { dismiss() }
                    .fontWeight(.medium)
                    .foregroundColor(.themeAccent)
            }
        }
        .alert(
            "Delete Log?",
            isPresented: $showDeleteAlert
        ) {
            Button("Delete", role: .destructive) {
                viewModel.deleteLog()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(
                "This will permanently remove this day's log " +
                    "and all associated symptoms."
            )
        }
        .onDisappear {
            viewModel.save()
        }
    }
}
