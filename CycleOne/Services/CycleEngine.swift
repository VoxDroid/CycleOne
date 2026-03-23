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
    func predictNextPeriodStart(from cycles: [CycleSnapshot]) -> Date? {
        guard !cycles.isEmpty else { return nil }
        // Simple implementation for skeleton
        return nil
    }

    func estimatedOvulationDate(nextPeriodStart: Date) -> Date {
        Calendar.current.date(byAdding: .day, value: -14, to: nextPeriodStart) ?? nextPeriodStart
    }

    func fertileWindow(ovulationDate: Date) -> [Date] {
        // Return 6 days surrounding ovulation
        []
    }

    func cyclesAreIrregular(_ cycles: [CycleSnapshot]) -> Bool {
        false
    }
}
