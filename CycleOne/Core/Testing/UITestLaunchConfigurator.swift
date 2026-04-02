//
//  UITestLaunchConfigurator.swift
//  CycleOne
//

import CoreData
import Foundation
import OSLog

enum UITestLaunchConfigurator {
    private static let logger = Logger(
        subsystem: "com.drei.CycleOne",
        category: "ui-testing"
    )

    private static var hasApplied = false

    #if DEBUG
        static func resetForTests() {
            hasApplied = false
        }
    #endif

    static func configureIfNeeded(
        context: NSManagedObjectContext,
        arguments: [String] = ProcessInfo.processInfo.arguments,
        retryCount: Int = 0
    ) {
        guard arguments.contains("-ui-testing") else { return }
        guard !hasApplied else { return }

        if context.persistentStoreCoordinator?.persistentStores.isEmpty ?? true, retryCount < 20 {
            // Keep launch deterministic for UI tests by ensuring setup finishes before UI renders.
            Thread.sleep(forTimeInterval: 0.1)
            configureIfNeeded(
                context: context,
                arguments: arguments,
                retryCount: retryCount + 1
            )
            return
        }

        hasApplied = true

        if arguments.contains("-ui-testing-has-seen-onboarding") {
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        }

        context.performAndWait {
            if arguments.contains("-ui-testing-clear-data") {
                clearAllData(in: context)
            }

            if arguments.contains("-ui-testing-seed-insights") {
                seedInsightsData(in: context)
            }
        }
    }

    private static func clearAllData(in context: NSManagedObjectContext) {
        for entity in ["Symptom", "DayLog", "Cycle"] {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

            do {
                try context.execute(deleteRequest)
            } catch {
                logger.error("UI test clear failed for \(entity): \(error.localizedDescription)")
            }
        }

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                logger.error("UI test clear save failed: \(error.localizedDescription)")
            }
        }

        context.reset()
    }

    private static func seedInsightsData(in context: NSManagedObjectContext) {
        let baseDate = Date().startOfDay
        let seedDates = [
            baseDate.adding(days: -56),
            baseDate.adding(days: -28),
            baseDate,
        ]

        for (index, date) in seedDates.enumerated() {
            let log = DayLog(context: context)
            log.id = UUID()
            log.date = date
            log.flowLevel = FlowLevel(rawValue: Int16(index % 3 + 1))!.rawValue
            log.mood = Mood.allCases[index % Mood.allCases.count].rawValue
            log.energyLevel = EnergyLevel.allCases[index % EnergyLevel.allCases.count].rawValue
            log.painLevel = Int16((index + 1) * 2)
            log.notes = "Seed log \(index + 1)"

            let symptomType = SymptomType.defaults[index % SymptomType.defaults.count]
            let symptom = Symptom(context: context)
            symptom.id = symptomType.id
            symptom.name = symptomType.name
            symptom.category = symptomType.category.rawValue
            symptom.dayLog = log
            log.addToSymptoms(symptom)
        }

        do {
            try context.save()
            CycleManager.shared.fullSync(in: context)
        } catch {
            logger.error("UI test seed failed: \(error.localizedDescription)")
        }
    }
}
