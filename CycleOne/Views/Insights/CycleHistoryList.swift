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
                    .listRowBackground(Color.clear)
                }
            } else {
                Section {
                    ForEach(cycles) { cycle in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(cycle.startDate?.formatted(.dateTime.month(.wide).day().year()) ?? "Unknown")
                                    .font(.headline)
                                Spacer()
                                if cycle.cycleLength > 0 {
                                    PillBadge(text: "\(cycle.cycleLength) days", color: .themeAccent)
                                }
                            }

                            HStack(spacing: 12) {
                                HStack(spacing: 4) {
                                    Image(systemName: "drop.fill")
                                        .font(.caption2)
                                        .foregroundColor(.themePeriod)
                                    Text("\(cycle.periodLength) days period")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                } header: {
                    Text("Past Cycles")
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }
}
