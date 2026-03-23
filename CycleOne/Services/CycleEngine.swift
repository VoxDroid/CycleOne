//
//  CycleEngine.swift
//  CycleOne
//

import Foundation

class CycleEngine {
    private let defaultCycleLength = 28
    private let defaultPeriodLength = 5

    func predictNextPeriodStart(from cycles: [Cycle]) -> Date? {
        guard let lastCycle = cycles.last, let lastStart = lastCycle.startDate else { return nil }

        // Only use the last 3 cycles that are within healthy bounds (21-45 days)
        let validCycles = cycles.suffix(3).filter { $0.cycleLength >= 21 && $0.cycleLength <= 45 }

        let averageLength: Int = if validCycles.isEmpty {
            defaultCycleLength
        } else {
            Int(validCycles.map { Int($0.cycleLength) }.reduce(0, +) / validCycles.count)
        }

        let lengthToUse = averageLength > 0 ? averageLength : defaultCycleLength
        return Calendar.current.date(byAdding: .day, value: lengthToUse, to: lastStart)
    }

    func predictOvulation(from cycles: [Cycle]) -> Date? {
        guard let nextPeriod = predictNextPeriodStart(from: cycles) else { return nil }
        return Calendar.current.date(byAdding: .day, value: -14, to: nextPeriod)
    }

    func isCycleIrregular(cycles: [Cycle]) -> Bool {
        let validCycles = cycles.filter { $0.cycleLength >= 21 && $0.cycleLength <= 45 }
        guard validCycles.count >= 2 else { return false }

        let lengths = validCycles.map { Int($0.cycleLength) }
        guard let min = lengths.min(), let max = lengths.max() else { return false }
        return (max - min) > 10
    }
}
