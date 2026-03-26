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
    @Published var hasExistingLog = false

    private let date: Date
    private let context: NSManagedObjectContext
    private let persistenceController: PersistenceController

    var formattedDate: String {
        date.formatted(.dateTime.weekday(.wide).month(.wide).day().year())
    }

    init(
        date: Date,
        context: NSManagedObjectContext,
        persistenceController: PersistenceController = .shared
    ) {
        self.date = date.startOfDay
        self.context = context
        self.persistenceController = persistenceController
        loadExistingLog()
    }

    func loadExistingLog() {
        let request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        request.predicate = NSPredicate(
            format: "date == %@", date as NSDate
        )

        do {
            if let log = try context.fetch(request).first {
                flow = FlowLevel(rawValue: log.flowLevel) ?? .none
                mood = Mood(rawValue: log.mood) ?? .neutral
                energy = EnergyLevel(rawValue: log.energyLevel) ?? .medium
                painLevel = Double(log.painLevel)
                notes = log.notes ?? ""
                hasExistingLog = true

                if let existingSymptoms = log.symptoms as? Set<Symptom> {
                    selectedSymptoms = Set(
                        existingSymptoms.compactMap(\.id)
                    )
                }
            }
        } catch {
            Logger.storage.error(
                "Failed to load log for \(self.date): \(error.localizedDescription)"
            )
        }
    }

    func save() {
        // Don't save empty logs
        guard hasContent else { return }

        let logRequest: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        logRequest.predicate = NSPredicate(
            format: "date == %@", date as NSDate
        )

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
            hasExistingLog = true
            Logger.storage.info("Saved log for \(self.date)")
        } catch {
            Logger.storage.error(
                "Failed to save log: \(error.localizedDescription)"
            )
        }
    }

    func deleteLog() {
        let request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        request.predicate = NSPredicate(
            format: "date == %@", date as NSDate
        )

        do {
            let results = try context.fetch(request)
            for log in results {
                // Delete associated symptoms first
                if let symptoms = log.symptoms as? Set<Symptom> {
                    for symptom in symptoms {
                        context.delete(symptom)
                    }
                }
                context.delete(log)
            }
            try context.save()
            hasExistingLog = false
            resetFields()
            Logger.storage.info(
                "Deleted log for \(self.date)"
            )
        } catch {
            Logger.storage.error(
                "Failed to delete log: \(error.localizedDescription)"
            )
        }
    }

    /// Whether the form has any user-entered content
    private var hasContent: Bool {
        flow != .none
            || mood != .neutral
            || energy != .medium
            || painLevel > 0
            || !notes.isEmpty
            || !selectedSymptoms.isEmpty
    }

    private func resetFields() {
        flow = .none
        mood = .neutral
        energy = .medium
        painLevel = 0
        notes = ""
        selectedSymptoms = []
    }

    private func updateSymptoms(for log: DayLog) {
        if let existing = log.symptoms as? Set<Symptom> {
            for symptom in existing {
                context.delete(symptom)
            }
        }
        log.symptoms = []

        for id in selectedSymptoms {
            if let type = SymptomType.defaults.first(
                where: { $0.id == id }
            ) {
                let symptom = Symptom(context: context)
                symptom.id = id
                symptom.name = type.name
                symptom.category = type.category.rawValue
                symptom.dayLog = log
                log.addToSymptoms(symptom)
            }
        }
    }

    private func startNewCycleIfNeeded() {
        let cycleRequest: NSFetchRequest<Cycle> = Cycle.fetchRequest()
        cycleRequest.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \Cycle.startDate, ascending: false
            ),
        ]
        cycleRequest.fetchLimit = 1

        do {
            let lastCycles = try context.fetch(cycleRequest)
            if let last = lastCycles.first {
                let diff = date.days(
                    from: last.startDate ?? Date()
                )
                if diff >= 20 {
                    createNewCycle()
                }
            } else {
                createNewCycle()
            }
        } catch {
            Logger.storage.error(
                "Failed to check last cycle: \(error.localizedDescription)"
            )
        }
    }

    private func createNewCycle() {
        let newCycle = Cycle(context: context)
        newCycle.id = UUID()
        newCycle.startDate = date
        newCycle.createdAt = Date()
        Logger.storage.info(
            "Created new cycle starting \(self.date)"
        )
    }
}
