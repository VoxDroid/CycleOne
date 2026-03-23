//
//  LogView.swift
//  CycleOne
//

import CoreData
import SwiftUI

struct LogView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: LogViewModel

    init(date: Date, context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: LogViewModel(date: date, context: context))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Flow") {
                    FlowPickerView(selection: $viewModel.flow)
                }

                Section("Mood & Energy") {
                    HStack {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            VStack {
                                Image(systemName: mood.icon)
                                    .font(.title2)
                                    .padding(8)
                                    .background(viewModel.mood == mood ? Color.themeAccent.opacity(0.2) : Color.clear)
                                    .clipShape(Circle())
                                Text(mood.description)
                                    .font(.caption2)
                            }
                            .frame(maxWidth: .infinity)
                            .onTapGesture { viewModel.mood = mood }
                        }
                    }
                    .padding(.vertical, 8)

                    HStack {
                        ForEach(EnergyLevel.allCases, id: \.self) { energy in
                            VStack {
                                Image(systemName: energy.icon)
                                    .font(.title2)
                                    .padding(8)
                                    .background(viewModel.energy == energy ? Color.themeAccent.opacity(0.2) : Color
                                        .clear)
                                    .clipShape(Circle())
                                Text(energy.description)
                                    .font(.caption2)
                            }
                            .frame(maxWidth: .infinity)
                            .onTapGesture { viewModel.energy = energy }
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section("Pain Level: \(Int(viewModel.painLevel))") {
                    Slider(value: $viewModel.painLevel, in: 0 ... 10, step: 1)
                        .accentColor(.themePeriod)
                }

                Section("Symptoms") {
                    SymptomGridView(selectedSymptoms: $viewModel.selectedSymptoms, symptoms: SymptomType.defaults)
                }

                Section("Notes") {
                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 100)
                        .onChange(of: viewModel.notes) { _, newValue in
                            if newValue.count > 500 {
                                viewModel.notes = String(newValue.prefix(500))
                            }
                        }
                }
            }
            .navigationTitle("Log Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        viewModel.save()
                        dismiss()
                    }
                    .bold()
                }
            }
        }
    }
}
