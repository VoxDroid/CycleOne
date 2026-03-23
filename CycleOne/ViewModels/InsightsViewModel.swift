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

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        calculateStats()
    }

    func calculateStats() {
        let request: NSFetchRequest<Cycle> = Cycle.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Cycle.startDate, ascending: false)]

        do {
            let cycles = try context.fetch(request)
            recentCycles = cycles
            totalCycles = cycles.count

            let validCycles = cycles.filter { $0.cycleLength > 0 }
            if !validCycles.isEmpty {
                avgCycleLength = Double(validCycles.map { Int($0.cycleLength) }.reduce(0, +)) /
                    Double(validCycles.count)
                shortestCycle = validCycles.map { Int($0.cycleLength) }.min() ?? 0
                longestCycle = validCycles.map { Int($0.cycleLength) }.max() ?? 0
            }

            let periodCycles = cycles.filter { $0.periodLength > 0 }
            if !periodCycles.isEmpty {
                avgPeriodLength = Double(periodCycles.map { Int($0.periodLength) }.reduce(0, +)) /
                    Double(periodCycles.count)
            }

            // Top symptoms
            calculateTopSymptoms()
        } catch {
            Logger.storage.error("Failed to calculate insights: \(error.localizedDescription)")
        }
    }

    private func calculateTopSymptoms() {
        let request: NSFetchRequest<Symptom> = Symptom.fetchRequest()
        do {
            let symptoms = try context.fetch(request)
            let counts = symptoms.reduce(into: [String: Int]()) { counts, symptom in
                if let name = symptom.name {
                    counts[name, default: 0] += 1
                }
            }
            topSymptoms = Array(counts.sorted { $0.value > $1.value }.prefix(3).map(\.key))
        } catch {
            Logger.storage.error("Failed to fetch symptoms for stats: \(error.localizedDescription)")
        }
    }
}
