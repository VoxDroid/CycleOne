//
//  CalendarDayCell.swift
//  CycleOne
//

import SwiftUI

struct CalendarDayCell: View {
    let date: Date
    let status: DayStatus
    let isToday: Bool
    let isSelected: Bool

    var body: some View {
        ZStack {
            // Fill for period/predicted/ovulation
            if let color = status.fillColor {
                Circle()
                    .fill(color.opacity(status.isPredicted ? 0.3 : 0.8))
            }

            // Ring for today
            if isToday {
                Circle()
                    .stroke(Color.themeAccent, lineWidth: 2)
            }

            // Text
            Text("\(Calendar.current.component(.day, from: date))")
                .font(.system(.body, design: .rounded))
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(textColor)

            // Dot for logs (if not a period day)
            if status.hasLogs, status.flow == .none {
                VStack {
                    Spacer()
                    Circle()
                        .fill(Color.secondary.opacity(0.5))
                        .frame(width: 4, height: 4)
                        .padding(.bottom, 4)
                }
            }
        }
        .aspectRatio(1, contentMode: .fill)
        .overlay(
            Circle()
                .stroke(Color.themeAccent, lineWidth: isSelected ? 2 : 0)
        )
    }

    private var textColor: Color {
        if status.fillColor != nil, !status.isPredicted {
            return .white
        }
        return .primary
    }
}

struct DayStatus {
    var flow: FlowLevel = .none
    var isPredicted: Bool = false
    var isOvulation: Bool = false
    var hasLogs: Bool = false

    var fillColor: Color? {
        if flow != .none { return .themePeriod }
        if isPredicted { return .themePeriod }
        if isOvulation { return .themeOvulation }
        return nil
    }
}
