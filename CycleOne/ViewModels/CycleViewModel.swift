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

        scheduleNotifications()
    }

    private func scheduleNotifications() {
        if let nextPeriod = nextPeriodDate {
            NotificationService.shared.schedulePeriodAlert(for: nextPeriod)

            let ovulation = engine.estimatedOvulationDate(nextPeriodStart: nextPeriod)
            if let firstFertileDay = engine.fertileWindow(ovulationDate: ovulation).first {
                NotificationService.shared.scheduleFertileWindowAlert(for: firstFertileDay)
            }
        }
    }

    enum DayStatus {
        case none, period, predictedPeriod, fertile, ovulation
    }

    func status(for date: Date) -> DayStatus {
        let normalizedDate = Calendar.current.startOfDay(for: date)

        // 1. Check for logged period
        if cycles.contains(where: { cycle in
            guard let start = cycle.startDate else { return false }
            let end = Calendar.current.date(byAdding: .day, value: Int(cycle.periodLength), to: start) ?? start
            return normalizedDate >= start && normalizedDate < end
        }) {
            return .period
        }

        // 2. Check for predicted period
        if let nextStart = nextPeriodDate {
            let predictedEnd = Calendar.current.date(byAdding: .day, value: 5, to: nextStart) ?? nextStart
            if normalizedDate >= nextStart, normalizedDate < predictedEnd {
                return .predictedPeriod
            }

            // 3. Check for fertile window/ovulation
            let ovulation = engine.estimatedOvulationDate(nextPeriodStart: nextStart)
            if Calendar.current.isDate(normalizedDate, inSameDayAs: ovulation) {
                return .ovulation
            }

            let fertileWindow = engine.fertileWindow(ovulationDate: ovulation)
            if fertileWindow.contains(where: { Calendar.current.isDate($0, inSameDayAs: normalizedDate) }) {
                return .fertile
            }
        }

        return .none
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
