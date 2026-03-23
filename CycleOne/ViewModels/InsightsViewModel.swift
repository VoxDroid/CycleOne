//
//  InsightsViewModel.swift
//  CycleOne
//
//  Created by Antigravity on 3/23/26.
//

import Combine
import CoreData
import Foundation
import OSLog

class InsightsViewModel: NSObject, ObservableObject {
    @Published var averageCycleLength: Int = 0
    @Published var averagePeriodLength: Int = 0
    @Published var cycleHistory: [Cycle] = []
    @Published var topSymptoms: [String] = []

    private let context: NSManagedObjectContext
    private var fetchedResultsController: NSFetchedResultsController<Cycle>!

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
        calculateStats()
    }

    private func setupFetchedResultsController() {
        let request: NSFetchRequest<Cycle> = Cycle.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Cycle.startDate, ascending: false)]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            self.cycleHistory = fetchedResultsController.fetchedObjects ?? []
        } catch {
            Logger.storage.error("Failed to fetch cycles for insights: \(error.localizedDescription)")
        }
    }

    func calculateStats() {
        let cycles = fetchedResultsController.fetchedObjects ?? []
        guard !cycles.isEmpty else { return }

        // Last 6 cycles for average
        let recentCycles = Array(cycles.prefix(6))

        let validCycleLengths = recentCycles.map { Int($0.cycleLength) }.filter { $0 > 0 }
        if !validCycleLengths.isEmpty {
            self.averageCycleLength = validCycleLengths.reduce(0, +) / validCycleLengths.count
        }

        let validPeriodLengths = recentCycles.map { Int($0.periodLength) }.filter { $0 > 0 }
        if !validPeriodLengths.isEmpty {
            self.averagePeriodLength = validPeriodLengths.reduce(0, +) / validPeriodLengths.count
        }

        calculateTopSymptoms()
    }

    private func calculateTopSymptoms() {
        let logRequest: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        // Last 30 days for symptoms
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        logRequest.predicate = NSPredicate(format: "date >= %@", thirtyDaysAgo as NSDate)

        do {
            let logs = try context.fetch(logRequest)
            var counts: [String: Int] = [:]

            for log in logs {
                if let symptoms = log.symptoms as? Set<Symptom> {
                    for symptom in symptoms {
                        if let name = symptom.name {
                            counts[name, default: 0] += 1
                        }
                    }
                }
            }

            self.topSymptoms = counts.sorted { $0.value > $1.value }
                .prefix(5)
                .map(\.key)
        } catch {
            Logger.storage.error("Failed to calculate top symptoms: \(error.localizedDescription)")
        }
    }
}

extension InsightsViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.cycleHistory = self.fetchedResultsController.fetchedObjects ?? []
            self.calculateStats()
        }
    }
}
