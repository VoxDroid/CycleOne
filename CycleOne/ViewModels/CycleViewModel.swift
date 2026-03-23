//
//  CycleViewModel.swift
//  CycleOne
//
//  Created by Antigravity on 3/23/26.
//

import Combine
import CoreData
import Foundation
import OSLog

class CycleViewModel: NSObject, ObservableObject {
    @Published var cycles: [Cycle] = []
    @Published var nextPeriodDate: Date?
    @Published var daysUntilNextPeriod: Int?
    @Published var isFertileToday: Bool = false

    private let context: NSManagedObjectContext
    private let engine = CycleEngine()
    private var fetchedResultsController: NSFetchedResultsController<Cycle>!

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        super.init()
        setupFetchedResultsController()
        refreshData()
    }

    private func setupFetchedResultsController() {
        let request: NSFetchRequest<Cycle> = Cycle.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Cycle.startDate, ascending: true)]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
            self.cycles = fetchedResultsController.fetchedObjects ?? []
        } catch {
            Logger.storage.error("Failed to fetch cycles: \(error.localizedDescription)")
        }
    }

    func refreshData() {
        let snapshots = cycles.compactMap { cycle -> CycleSnapshot? in
            guard let startDate = cycle.startDate else { return nil }
            return CycleSnapshot(
                startDate: startDate,
                cycleLength: Int(cycle.cycleLength),
                periodLength: Int(cycle.periodLength)
            )
        }

        self.nextPeriodDate = engine.predictNextPeriodStart(from: snapshots)

        if let nextDate = nextPeriodDate {
            let diff = Calendar.current.dateComponents([.day], from: Date(), to: nextDate).day ?? 0
            self.daysUntilNextPeriod = max(0, diff)

            let ovulation = engine.estimatedOvulationDate(nextPeriodStart: nextDate)
            let fertileWindow = engine.fertileWindow(ovulationDate: ovulation)
            self.isFertileToday = fertileWindow.contains { Calendar.current.isDateInToday($0) }
        }
    }
}

extension CycleViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.cycles = self.fetchedResultsController.fetchedObjects ?? []
            self.refreshData()
        }
    }
}
