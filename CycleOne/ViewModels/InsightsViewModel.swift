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

    deinit {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }

    init(context: NSManagedObjectContext) {
        self.context = context

        // Perform a one-time full sync to fix any legacy orphaned cycles
        CycleManager.shared.fullSync(in: context)
        calculateStats()

        // Auto-refresh when Core Data saves (log created/updated/deleted)
        // Register after initial sync to avoid re-entrant calculateStats
        NotificationCenter.default.publisher(
            for: .NSManagedObjectContextDidSave, object: context
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.calculateStats()
        }
        .store(in: &cancellables)
    }

    func calculateStats() {
        let request: NSFetchRequest<Cycle> = Cycle.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Cycle.startDate, ascending: false),
        ]

        do {
            let cycles = try context.fetch(request)
            recentCycles = cycles
            totalCycles = cycles.count

            calculateCycleStats(from: cycles)
            calculatePeriodStats(from: cycles)
            calculateSymptomStats()
            calculateMoodStats()
            calculatePainStats()
        } catch {
            Logger.storage.error("Failed to fetch cycles: \(error)")
        }
    }

    private func calculateCycleStats(from cycles: [Cycle]) {
        let validCycles = cycles.filter { $0.cycleLength > 0 }
        if !validCycles.isEmpty {
            let lengths = validCycles.map { Int($0.cycleLength) }
            avgCycleLength = Double(lengths.reduce(0, +)) / Double(lengths.count)
            shortestCycle = lengths.min()!
            longestCycle = lengths.max()!
            cycleLengthHistory = validCycles.reversed().map { cycle in
                (date: cycle.startDate!, length: Int(cycle.cycleLength))
            }
            Logger.storage.debug(
                "DEBUG InsightsViewModel.calculateCycleStats completed"
            )
        } else {
            avgCycleLength = 0
            shortestCycle = 0
            longestCycle = 0
            cycleLengthHistory = []
        }
    }

    private func calculatePeriodStats(from cycles: [Cycle]) {
        let periodCycles = cycles.filter { $0.periodLength > 0 }
        if !periodCycles.isEmpty {
            let totalLength = periodCycles.map { Int($0.periodLength) }.reduce(0, +)
            avgPeriodLength = Double(totalLength) / Double(periodCycles.count)
        } else {
            avgPeriodLength = 0
        }
    }

    private func calculateSymptomStats() {
        let request: NSFetchRequest<Symptom> = Symptom.fetchRequest()
        do {
            let symptoms = try context.fetch(request)
            let counts = symptoms.reduce(into: [String: Int]()) { counts, symptom in
                let displayName = SymptomType.localizedName(
                    forID: symptom.id,
                    fallbackName: symptom.name ?? ""
                )

                if !displayName.isEmpty {
                    counts[displayName, default: 0] += 1
                }
            }
            topSymptoms = Array(counts.sorted { $0.value > $1.value }
                .prefix(3)
                .map(\.key))
            symptomDistribution = counts.sorted { $0.value > $1.value }
                .prefix(6)
                .map { (name: $0.key, count: $0.value) }
        } catch {
            Logger.storage.error("Failed to fetch symptoms: \(error.localizedDescription)")
        }
    }

    private func calculateMoodStats() {
        let logRequest: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        do {
            let logs = try context.fetch(logRequest)
            var moods: [String: Int] = [:]
            for log in logs {
                let moodVal = Mood(rawValue: log.mood) ?? .neutral
                moods[moodVal.description, default: 0] += 1
            }
            moodDistribution = moods
        } catch {
            Logger.storage.error("Failed to fetch mood stats: \(error.localizedDescription)")
        }
    }

    private func calculatePainStats() {
        let logRequest: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        do {
            let logs = try context.fetch(logRequest)
            totalLogsCount = logs.count
            let painLogs = logs.filter { $0.painLevel > 0 }
            if !painLogs.isEmpty {
                avgPainLevel = Double(painLogs.map { Int($0.painLevel) }.reduce(0, +)) / Double(painLogs.count)
            } else {
                avgPainLevel = 0
            }
        } catch {
            Logger.storage.error("Failed to fetch pain stats: \(error.localizedDescription)")
        }
    }
}
