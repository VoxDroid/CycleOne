//
//  TestDataSeeder.swift
//  CycleOne
//

import CoreData
import Foundation
import OSLog

enum TestDataSeeder {
    /// Toggle this to enable/disable test data seeding programmatically.
    static let isEnabled = true

    static func seed(context: NSManagedObjectContext) {
        guard isEnabled else { return }

        // Check if data already exists to avoid double seeding
        let request: NSFetchRequest<Cycle> = Cycle.fetchRequest()
        do {
            let count = try context.count(for: request)
            if count > 0 { return }

            Logger.storage.info("🌱 Seeding test data...")

            let calendar = Calendar.current
            let today = Date().startOfDay

            // 1. Past Cycle (28 days ago)
            guard let pastStartDate = calendar.date(byAdding: .day, value: -28, to: today) else { return }
            let cycle1 = Cycle(context: context)
            cycle1.id = UUID()
            cycle1.startDate = pastStartDate
            cycle1.periodLength = 5
            cycle1.cycleLength = 28

            // Create logs for past period
            for index in 0 ..< 5 {
                guard let logDate = calendar.date(byAdding: .day, value: index, to: pastStartDate) else { continue }
                let log = DayLog(context: context)
                log.id = UUID()
                log.date = logDate
                log.flowLevel = index == 2 ? 3 : 1 // Heavy on day 3
                log.mood = Int16(index % 5)
                log.energyLevel = 1

                // Add a symptom to some days
                if index % 2 == 0 {
                    let symptom = Symptom(context: context)
                    symptom.id = "cramps"
                    symptom.name = "Cramps"
                    symptom.category = SymptomCategory.physical.rawValue
                    symptom.dayLog = log
                }
            }

            // 2. Current Cycle (Started 2 days ago)
            let currentStartDate = today.addingTimeInterval(-86400 * 2)
            let cycle2 = Cycle(context: context)
            cycle2.id = UUID()
            cycle2.startDate = currentStartDate
            cycle2.periodLength = 5

            for index in 0 ..< 3 {
                guard let logDate = calendar.date(byAdding: .day, value: index, to: currentStartDate) else { continue }
                let log = DayLog(context: context)
                log.id = UUID()
                log.date = logDate
                log.flowLevel = 2 // Medium
                log.mood = 1 // Neutral
                log.energyLevel = 1
                log.notes = "Seeded test entry \(index + 1)"
            }

            try context.save()
            Logger.storage.info("✅ Test data seeded successfully.")
        } catch {
            Logger.storage.error("❌ Failed to seed test data: \(error.localizedDescription)")
        }
    }
}
