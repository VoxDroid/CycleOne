//
//  LogViewModel.swift
//  CycleOne
//

import Combine
import CoreData
import Foundation
import OSLog

final class LogViewModel: ObservableObject {
    @Published var flow: FlowLevel = .none
    @Published var mood: Mood = .neutral
    @Published var energy: EnergyLevel = .medium
    @Published var painLevel: Double = 0
    @Published var notes: String = ""
    @Published var selectedSymptoms: Set<String> = []

    private let date: Date
    private let context: NSManagedObjectContext
    private let persistenceController: PersistenceController

    init(date: Date, context: NSManagedObjectContext, persistenceController: PersistenceController = .shared) {
        self.date = date.startOfDay
        self.context = context
        self.persistenceController = persistenceController
        loadExistingLog()
    }

    func loadExistingLog() {
        let request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", date as NSDate)

        do {
            if let log = try context.fetch(request).first {
                flow = FlowLevel(rawValue: log.flowLevel) ?? .none
                mood = Mood(rawValue: log.mood) ?? .neutral
                energy = EnergyLevel(rawValue: log.energyLevel) ?? .medium
                painLevel = Double(log.painLevel)
                notes = log.notes ?? ""
                selectedSymptoms = Set(log.symptoms?.compactMap { ($0 as? Symptom)?.id } ?? [])
            }
        } catch {
            Logger.storage.error("Failed to load log for \(self.date): \(error.localizedDescription)")
        }
    }

    func save() {
        let logRequest: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        logRequest.predicate = NSPredicate(format: "date == %@", date as NSDate)

        do {
            let results = try context.fetch(logRequest)
            let log = results.first ?? DayLog(context: context)

            log.id = log.id ?? UUID()
            log.date = date
            log.flowLevel = flow.rawValue
            log.mood = mood.rawValue
            log.energyLevel = energy.rawValue
            log.painLevel = Int16(painLevel)
            log.notes = notes

            // Sync Symptoms
            updateSymptoms(for: log)

            // Auto Cycle creation
            if flow != .none {
                startNewCycleIfNeeded()
            }

            try context.save()
            Logger.storage.info("Saved log for \(self.date)")
        } catch {
            Logger.storage.error("Failed to save log: \(error.localizedDescription)")
        }
    }

    private func updateSymptoms(for log: DayLog) {
        // Clear current symptoms
        log.symptoms = []

        for id in selectedSymptoms {
            if let type = SymptomType.defaults.first(where: { $0.id == id }) {
                let symptom = Symptom(context: context)
                symptom.id = id
                symptom.name = type.name
                symptom.category = type.category.rawValue
                log.addToSymptoms(symptom)
            }
        }
    }

    private func startNewCycleIfNeeded() {
        let cycleRequest: NSFetchRequest<Cycle> = Cycle.fetchRequest()
        cycleRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Cycle.startDate, ascending: false)]
        cycleRequest.fetchLimit = 1

        do {
            let lastCycles = try context.fetch(cycleRequest)
            if let last = lastCycles.first {
                let diff = date.days(from: last.startDate ?? Date())
                if diff >= 20 {
                    createNewCycle()
                }
            } else {
                createNewCycle()
            }
        } catch {
            Logger.storage.error("Failed to check last cycle: \(error.localizedDescription)")
        }
    }

    private func createNewCycle() {
        let newCycle = Cycle(context: context)
        newCycle.id = UUID()
        newCycle.startDate = date
        newCycle.createdAt = Date()
        Logger.storage.info("Created new cycle starting \(self.date)")
    }
}
