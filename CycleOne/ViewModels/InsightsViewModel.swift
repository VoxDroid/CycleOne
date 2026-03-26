//
//  InsightsViewModel.swift
//  CycleOne
//

import Combine
import CoreData
import Foundation
import OSLog
import SwiftUI

final class InsightsViewModel: ObservableObject {
    @Published var avgCycleLength: Double = 0
    @Published var avgPeriodLength: Double = 0
    @Published var shortestCycle: Int = 0
    @Published var longestCycle: Int = 0
    @Published var totalCycles: Int = 0
    @Published var topSymptoms: [String] = []
    @Published var recentCycles: [Cycle] = []
    @Published var cycleLengthHistory: [(date: Date, length: Int)] = []
    @Published var symptomDistribution: [(name: String, count: Int)] = []
    @Published var moodDistribution: [String: Int] = [:]
    @Published var avgPainLevel: Double = 0
    @Published var totalLogsCount: Int = 0

    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    init(context: NSManagedObjectContext) {
        self.context = context

        // Auto-refresh when Core Data saves (log created/updated/deleted)
        NotificationCenter.default.publisher(
            for: .NSManagedObjectContextDidSave, object: context
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.calculateStats()
        }
        .store(in: &cancellables)

        calculateStats()
    }

    func calculateStats() {
        let request: NSFetchRequest<Cycle> = Cycle.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(
                keyPath: \Cycle.startDate, ascending: false
            ),
        ]

        do {
            let cycles = try context.fetch(request)
            recentCycles = cycles
            totalCycles = cycles.count

            let validCycles = cycles.filter { $0.cycleLength > 0 }
            if !validCycles.isEmpty {
                avgCycleLength =
                    Double(
                        validCycles.map { Int($0.cycleLength) }
                            .reduce(0, +)
                    ) / Double(validCycles.count)
                shortestCycle =
                    validCycles.map { Int($0.cycleLength) }.min()
                        ?? 0
                longestCycle =
                    validCycles.map { Int($0.cycleLength) }.max()
                        ?? 0

                // Build cycle length history (ascending)
                cycleLengthHistory = validCycles.reversed()
                    .compactMap { cycle in
                        guard let date = cycle.startDate else {
                            return nil
                        }
                        return (
                            date: date,
                            length: Int(cycle.cycleLength)
                        )
                    }
            } else {
                avgCycleLength = 0
                shortestCycle = 0
                longestCycle = 0
                cycleLengthHistory = []
            }

            let periodCycles = cycles.filter {
                $0.periodLength > 0
            }
            if !periodCycles.isEmpty {
                avgPeriodLength =
                    Double(
                        periodCycles.map { Int($0.periodLength) }
                            .reduce(0, +)
                    ) / Double(periodCycles.count)
            } else {
                avgPeriodLength = 0
            }

            calculateTopSymptoms()
            calculateLogStats()
        } catch {
            Logger.storage.error(
                "Failed to calculate insights: \(error.localizedDescription)"
            )
        }
    }

    private func calculateTopSymptoms() {
        let request: NSFetchRequest<Symptom> = Symptom.fetchRequest()
        do {
            let symptoms = try context.fetch(request)
            let counts = symptoms.reduce(
                into: [String: Int]()
            ) { counts, symptom in
                if let name = symptom.name {
                    counts[name, default: 0] += 1
                }
            }
            topSymptoms = Array(
                counts.sorted { $0.value > $1.value }.prefix(3)
                    .map(\.key)
            )
            symptomDistribution = counts
                .sorted { $0.value > $1.value }
                .prefix(6)
                .map { (name: $0.key, count: $0.value) }
        } catch {
            Logger.storage.error(
                "Failed to fetch symptoms: \(error.localizedDescription)"
            )
        }
    }

    private func calculateLogStats() {
        let logRequest: NSFetchRequest<DayLog> =
            DayLog.fetchRequest()
        do {
            let logs = try context.fetch(logRequest)
            totalLogsCount = logs.count

            // Pain average
            let painLogs = logs.filter { $0.painLevel > 0 }
            if !painLogs.isEmpty {
                avgPainLevel =
                    Double(
                        painLogs.map { Int($0.painLevel) }
                            .reduce(0, +)
                    ) / Double(painLogs.count)
            } else {
                avgPainLevel = 0
            }

            // Mood distribution
            var moods: [String: Int] = [:]
            for log in logs {
                let moodVal = Mood(rawValue: log.mood)
                    ?? .neutral
                moods[moodVal.description, default: 0] += 1
            }
            moodDistribution = moods
        } catch {
            Logger.storage.error(
                "Failed to fetch log stats: \(error.localizedDescription)"
            )
        }
    }
}
