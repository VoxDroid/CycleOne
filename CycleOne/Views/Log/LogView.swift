//
//  LogView.swift
//  CycleOne
//

import CoreData
import Foundation
import OSLog
import SwiftUI

struct LogView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CycleViewModel
    let date: Date

    @State private var flow: FlowLevel = .none
    @State private var mood: Mood = .neutral
    @State private var notes: String = ""
    @State private var selectedSymptoms: Set<String> = []

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Menstrual Flow")) {
                    Picker("Flow", selection: $flow) {
                        ForEach(FlowLevel.allCases, id: \.self) { level in
                            Text(level.description).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Mood")) {
                    HStack {
                        ForEach(Mood.allCases, id: \.self) { item in
                            VStack {
                                Image(systemName: item.icon)
                                    .font(.title2)
                                    .foregroundColor(mood == item ? .themeAccent : .secondary)
                                    .onTapGesture {
                                        mood = item
                                    }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text("Symptoms")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(SymptomType.defaults) { symptom in
                                Text(symptom.name)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(selectedSymptoms.contains(symptom.id) ? Color.themePeriod : Color
                                        .secondary
                                        .opacity(0.1))
                                    .foregroundColor(selectedSymptoms.contains(symptom.id) ? .white : .primary)
                                    .cornerRadius(20)
                                    .onTapGesture {
                                        if selectedSymptoms.contains(symptom.id) {
                                            selectedSymptoms.remove(symptom.id)
                                        } else {
                                            selectedSymptoms.insert(symptom.id)
                                        }
                                    }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section(header: Text("Notes (Max 500 chars)")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                        .onChange(of: notes) { _, newValue in
                            if newValue.count > 500 {
                                notes = String(newValue.prefix(500))
                            }
                        }
                }
            }
            .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: {
                        saveLog()
                        dismiss()
                    })
                    .bold()
                }
            }
        }
    }

    private func saveLog() {
        let viewContext = PersistenceController.shared.container.viewContext
        let normalizedDate = Calendar.current.startOfDay(for: date)

        let fetchRequest: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "date == %@", normalizedDate as NSDate)

        do {
            let results = try viewContext.fetch(fetchRequest)
            let log = results.first ?? DayLog(context: viewContext)

            log.id = log.id ?? UUID()
            log.date = normalizedDate
            log.flowLevel = flow.rawValue
            log.mood = mood.rawValue
            log.notes = notes

            // Manage Symptoms
            let symptomRequest: NSFetchRequest<Symptom> = Symptom.fetchRequest()
            symptomRequest.predicate = NSPredicate(format: "id IN %@", Array(selectedSymptoms))

            let existingSymptoms = try viewContext.fetch(symptomRequest)
            let existingIds = Set(existingSymptoms.compactMap(\.id))

            // 1. Clear current symptoms
            log.symptoms = []

            // 2. Add existing ones
            for symptom in existingSymptoms {
                log.addToSymptoms(symptom)
            }

            // 3. Create missing ones if needed (optional, but good for completeness)
            for id in selectedSymptoms where !existingIds.contains(id) {
                if let type = SymptomType.defaults.first(where: { $0.id == id }) {
                    let newSymptom = Symptom(context: viewContext)
                    newSymptom.id = id
                    newSymptom.name = type.name
                    newSymptom.category = type.category.rawValue
                    log.addToSymptoms(newSymptom)
                }
            }

            // Auto Cycle logic
            if flow == .medium || flow == .heavy {
                startNewCycleIfNeeded(context: viewContext, startDate: normalizedDate)
            }

            try viewContext.save()
            Logger.storage.info("Successfully saved log for \(date)")
        } catch {
            Logger.storage.error("Error saving log: \(error.localizedDescription)")
        }
    }

    private func startNewCycleIfNeeded(context: NSManagedObjectContext, startDate: Date) {
        let cycleRequest: NSFetchRequest<Cycle> = Cycle.fetchRequest()
        cycleRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Cycle.startDate, ascending: false)]
        cycleRequest.fetchLimit = 1

        do {
            let lastCycles = try context.fetch(cycleRequest)
            if let last = lastCycles.first {
                let diff = Calendar.current.dateComponents([.day], from: last.startDate ?? Date(), to: startDate)
                    .day ?? 0
                if diff >= 20 {
                    createNewCycle(context: context, startDate: startDate)
                }
            } else {
                createNewCycle(context: context, startDate: startDate)
            }
        } catch {
            Logger.storage.error("Failed to check last cycle: \(error.localizedDescription)")
        }
    }

    private func createNewCycle(context: NSManagedObjectContext, startDate: Date) {
        let newCycle = Cycle(context: context)
        newCycle.id = UUID()
        newCycle.startDate = startDate
        newCycle.createdAt = Date()
        Logger.storage.info("Automatic new cycle created starting \(startDate)")
    }
}
