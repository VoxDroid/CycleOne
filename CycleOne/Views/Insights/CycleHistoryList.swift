//
//  CycleHistoryList.swift
//  CycleOne
//

import SwiftUI

struct CycleHistoryList: View {
    @EnvironmentObject private var themeManager: ThemeManager
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
                    ForEach(Array(cycles.enumerated()), id: \.element.id) { index, cycle in
                        HStack(spacing: 12) {
                            // Timeline indicator
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(index == 0 ? Color.themeAccent : Color.secondary.opacity(0.3))
                                    .frame(width: 10, height: 10)
                                if index < cycles.count - 1 {
                                    Rectangle()
                                        .fill(Color.secondary.opacity(0.15))
                                        .frame(width: 2)
                                }
                            }
                            .frame(width: 10)

                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(cycle.startDate?.formatted(.dateTime.month(.wide).day().year()) ??
                                        "Unknown")
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
                        }
                        .padding(.vertical, 6)
                        .fadeSlideIn(delay: Double(index) * Theme.staggerDelay)
                    }
                } header: {
                    Text("Past Cycles")
                }
            }
        }
        .accessibilityIdentifier("CycleHistoryListRoot")
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }
}
