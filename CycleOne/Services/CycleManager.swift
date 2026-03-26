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
        // 1. Delete all existing cycles
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Cycle")
        if let cycles = try? context.fetch(fetchRequest) {
            for cycle in cycles {
                context.delete(cycle)
            }
        }
        try? context.save()

        // 2. Fetch all flow logs sorted by date
        let logRequest = NSFetchRequest<NSManagedObject>(entityName: "DayLog")
        logRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]

        guard let allLogs = try? context.fetch(logRequest) else {
            return
        }

        // Filter flow logs in Swift for absolute robustness
        let logs = allLogs.filter { log in
            let flowValue = log.value(forKey: "flowLevel")
            return extractInt16(from: flowValue) > 0
        }

        if logs.isEmpty {
            return
        }

        // 3. Reconstruct cycles
        var lastStartDate: Date?
        for log in logs {
            let dateValue = log.value(forKey: "date")
            let date = extractDate(from: dateValue)

            guard let validDate = date?.startOfDay else { continue }

            if let last = lastStartDate {
                let diff = validDate.days(from: last)
                if diff >= 20 {
                    createCycle(at: validDate, in: context)
                    lastStartDate = validDate
                }
            } else {
                // First ever flow log
                createCycle(at: validDate, in: context)
                lastStartDate = validDate
            }
        }

        // Ensure changes are processed before metrics update
        context.processPendingChanges()

        // 4. Update metrics for the newly created cycles
        updateCycleMetrics(in: context)
        try? context.save()
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
                let start = extractDate(from: startDateValue)

                guard let validStart = start else { continue }

                // Calculate Period Length (consecutive flow days)
                let periodLen = calculateConsecutiveFlowAt(
                    date: validStart,
                    in: context
                )
                cycle.setValue(Int16(periodLen), forKey: "periodLength")

                // Calculate Cycle Length (days until next cycle start)
                if index < cycles.count - 1 {
                    let nextStartValue = cycles[index + 1].value(forKey: "startDate")
                    let nextDate = extractDate(from: nextStartValue)

                    if let validNext = nextDate {
                        let length = validNext.days(from: validStart)
                        cycle.setValue(Int16(length), forKey: "cycleLength")
                    } else {
                        cycle.setValue(Int16(0), forKey: "cycleLength")
                    }
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
        if let date = value as? Date {
            return date
        } else if let nsDate = value as? NSDate {
            return nsDate as Date
        }
        return nil
    }

    private func extractInt16(from value: Any?) -> Int16 {
        if let number = value as? NSNumber {
            return number.int16Value
        } else if let val = value as? Int16 {
            return val
        } else if let val = value as? Int {
            return Int16(val)
        }
        return 0
    }

    /// Fully refreshes the cycle repository
    func fullSync(in context: NSManagedObjectContext) {
        rebuildAllCycles(in: context)
    }
}
