//
//  CalendarDayCell.swift
//  CycleOne
//

import SwiftUI

struct CalendarDayCell: View {
    // Legacy cell retained for API compatibility; current calendar uses NativeCalendarView.
    let date: Date
    let status: DayStatus
    let isToday: Bool
    let isSelected: Bool

    var body: some View {
        Color.clear
            .frame(width: 1, height: 1)
            .accessibilityHidden(true)
    }
}

struct DayStatus {
    var flow: FlowLevel = .none
    var isPredicted: Bool = false
    var isOvulation: Bool = false
    var isFertile: Bool = false
    var hasLogs: Bool = false

    var fillColor: Color? {
        if flow != .none { return .themePeriod }
        if isPredicted { return .themePeriod }
        if isOvulation { return .themeOvulation }
        return nil
    }
}
