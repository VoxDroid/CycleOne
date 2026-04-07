//
//  CycleManager.swift
//  CycleOne
//

import CoreData
import Foundation
import OSLog

final class CycleManager {
    static let shared = CycleManager()

    private init() {}

    func rebuildAllCycles(in context: NSManagedObjectContext) {
        clearExistingCycles(in: context)
        let logs = fetchFlowLogs(in: context)
        if logs.isEmpty {
            return
        }

        rebuildCycles(from: logs, in: context)

        context.processPendingChanges()
        updateCycleMetrics(in: context)
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                Logger.storage.error("Cycle rebuild save failed: \(error.localizedDescription)")
            }
        }
    }

    private func clearExistingCycles(in context: NSManagedObjectContext) {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Cycle")
        do {
            let cycles = try context.fetch(fetchRequest)
            for cycle in cycles {
                context.delete(cycle)
            }
        } catch {
            Logger.storage.error("Cycle cleanup fetch failed: \(error.localizedDescription)")
        }

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                Logger.storage.error("Cycle cleanup save failed: \(error.localizedDescription)")
            }
        }
    }

    private func fetchFlowLogs(in context: NSManagedObjectContext) -> [NSManagedObject] {
        let logRequest = NSFetchRequest<NSManagedObject>(entityName: "DayLog")
        logRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        do {
            let allLogs = try context.fetch(logRequest)
            return allLogs.filter { log in
                let flowValue = log.value(forKey: "flowLevel")
                return extractInt16(from: flowValue) > 0
            }
        } catch {
            Logger.storage.error("Cycle rebuild log fetch failed: \(error.localizedDescription)")
            return []
        }
    }

    private func rebuildCycles(
        from logs: [NSManagedObject],
        in context: NSManagedObjectContext
    ) {
        var lastStartDate: Date?

        for log in logs {
            let dateValue = log.value(forKey: "date")
            guard let validDate = extractDate(from: dateValue)?.startOfDay else {
                Logger.storage.error("Skipping DayLog with invalid date during cycle rebuild")
                continue
            }

            guard let last = lastStartDate else {
                createCycle(at: validDate, in: context)
                lastStartDate = validDate
                continue
            }

            if validDate.days(from: last) >= 20 {
                createCycle(at: validDate, in: context)
                lastStartDate = validDate
            }
        }
    }

    private func createCycle(at date: Date, in context: NSManagedObjectContext) {
        let cycle = NSEntityDescription.insertNewObject(forEntityName: "Cycle", into: context)
        cycle.setValue(UUID(), forKey: "id")
        cycle.setValue(date, forKey: "startDate")
        cycle.setValue(Date(), forKey: "createdAt")
    }

    /// Recalculates cycleLength and periodLength for all cycles in order.
    func updateCycleMetrics(in context: NSManagedObjectContext) {
        let cycleRequest = NSFetchRequest<NSManagedObject>(entityName: "Cycle")
        cycleRequest.sortDescriptors = [
            NSSortDescriptor(key: "startDate", ascending: true),
        ]

        do {
            let cycles = try context.fetch(cycleRequest)
            for (index, cycle) in cycles.enumerated() {
                let startDateValue = cycle.value(forKey: "startDate")
                guard let validStart = extractDate(from: startDateValue) else {
                    Logger.storage.error("Skipping Cycle with invalid startDate during metrics update")
                    continue
                }

                // Calculate Period Length (consecutive flow days)
                let periodLen = calculateConsecutiveFlowAt(
                    date: validStart,
                    in: context
                )
                cycle.setValue(Int16(periodLen), forKey: "periodLength")

                // Calculate Cycle Length (days until next cycle start)
                if index < cycles.count - 1 {
                    let nextStartValue = cycles[index + 1].value(forKey: "startDate")
                    cycle.setValue(
                        cycleLength(from: validStart, nextStartValue: nextStartValue),
                        forKey: "cycleLength"
                    )
                } else {
                    cycle.setValue(Int16(0), forKey: "cycleLength")
                }
            }
        } catch {
            Logger.storage.error("Cycle metrics update failed: \(error.localizedDescription)")
        }
    }

    private func calculateConsecutiveFlowAt(
        date: Date,
        in context: NSManagedObjectContext
    ) -> Int {
        var count = 0
        var currentDate = date.startOfDay
        let maxSearch = 12

        for _ in 0 ..< maxSearch {
            let startOfDay = currentDate
            let endOfDay = startOfDay.adding(days: 1)

            let request = NSFetchRequest<NSManagedObject>(entityName: "DayLog")
            request.predicate = NSPredicate(
                format: "date >= %@ AND date < %@",
                startOfDay as NSDate, endOfDay as NSDate
            )

            if let log = try? context.fetch(request).first {
                let flowVal = log.value(forKey: "flowLevel")
                if extractInt16(from: flowVal) > 0 {
                    count += 1
                    currentDate = currentDate.adding(days: 1)
                } else {
                    break
                }
            } else {
                break
            }
        }
        return count
    }

    private func extractDate(from value: Any?) -> Date? {
        value as? Date
    }

    private func extractInt16(from value: Any?) -> Int16 {
        (value as? NSNumber)?.int16Value ?? 0
    }

    private func cycleLength(
        from startDate: Date,
        nextStartValue: Any?
    ) -> Int16 {
        guard let nextDate = extractDate(from: nextStartValue) else {
            return 0
        }
        return Int16(nextDate.days(from: startDate))
    }

    #if DEBUG
        func testExtractDate(from value: Any?) -> Date? {
            extractDate(from: value)
        }

        func testExtractInt16(from value: Any?) -> Int16 {
            extractInt16(from: value)
        }

        func testCycleLength(from startDate: Date, nextStartValue: Any?) -> Int16 {
            cycleLength(from: startDate, nextStartValue: nextStartValue)
        }
    #endif

    /// Fully refreshes the cycle repository
    func fullSync(in context: NSManagedObjectContext) {
        // Ensure all Core Data operations execute on the context's queue
        if Thread.isMainThread {
            // If already on main thread, run directly to avoid deadlock
            rebuildAllCycles(in: context)
        } else {
            context.performAndWait {
                rebuildAllCycles(in: context)
            }
        }
    }
}
