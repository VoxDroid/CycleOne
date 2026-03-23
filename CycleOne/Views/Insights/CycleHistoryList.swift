//
//  CycleHistoryList.swift
//  CycleOne
//

import SwiftUI

struct CycleHistoryList: View {
    let cycles: [Cycle]

    var body: some View {
        List {
            if cycles.isEmpty {
                Section {
                    EmptyStateView(
                        icon: "calendar.badge.clock",
                        title: "No data yet",
                        message: "Your cycle history will appear here once you log your first period."
                    )
                }
            } else {
                ForEach(cycles) { cycle in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(cycle.startDate?.formatted(date: .long, time: .omitted) ?? "Unknown Start")
                            .font(.headline)

                        HStack {
                            if cycle.cycleLength > 0 {
                                PillBadge(text: "\(cycle.cycleLength) days total", color: .themeAccent)
                            }
                            if cycle.periodLength > 0 {
                                PillBadge(text: "\(cycle.periodLength) days period", color: .themePeriod)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("History")
    }
}
