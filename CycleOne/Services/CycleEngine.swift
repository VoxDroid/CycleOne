//
//  CycleEngine.swift
//  CycleOne
//
//  Created by Antigravity on 3/23/26.
//

import Foundation

struct CycleSnapshot {
    let startDate: Date
    let cycleLength: Int
    let periodLength: Int
}

class CycleEngine {
    private let defaultCycleLength = 28
    private let defaultPeriodLength = 5

    func predictNextPeriodStart(from cycles: [CycleSnapshot]) -> Date? {
        guard let lastCycle = cycles.last else { return nil }

        let averageLength = cycles.count > 0
            ? Int(cycles.map(\.cycleLength).reduce(0, +) / cycles.count)
            : defaultCycleLength

        let lengthToUse = averageLength > 0 ? averageLength : defaultCycleLength

        return Calendar.current.date(byAdding: .day, value: lengthToUse, to: lastCycle.startDate)
    }

    func estimatedOvulationDate(nextPeriodStart: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: -14, to: nextPeriodStart) ?? nextPeriodStart
    }

    func fertileWindow(ovulationDate: Date) -> [Date] {
        // High fertility: 5 days before ovulation up to ovulation day
        (0 ... 5).compactMap { day in
            Calendar.current.date(byAdding: .day, value: -day, to: ovulationDate)
        }.sorted()
    }

    func cyclesAreIrregular(_ cycles: [CycleSnapshot]) -> Bool {
        guard cycles.count >= 2 else { return false }
        let lengths = cycles.map(\.cycleLength)
        guard let min = lengths.min(), let max = lengths.max() else { return false }
        return (max - min) > 8
    }
}
