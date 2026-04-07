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
                        title: "insights.history.empty_title",
                        message: "insights.history.empty_message"
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
                                    Text(Self.formattedStartDate(cycle.startDate))
                                        .font(.headline)
                                    Spacer()
                                    if cycle.cycleLength > 0 {
                                        PillBadge(
                                            text: Self.cycleLengthText(cycle.cycleLength),
                                            color: .themeAccent
                                        )
                                    }
                                }

                                HStack(spacing: 12) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "drop.fill")
                                            .font(.caption2)
                                            .foregroundColor(.themePeriod)
                                        Text(Self.periodLengthText(cycle.periodLength))
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
                    Text("insights.history.past_cycles")
                }
            }
        }
        .accessibilityIdentifier("CycleHistoryListRoot")
        .navigationTitle("insights.history.title")
        .navigationBarTitleDisplayMode(.inline)
    }

    static func formattedStartDate(_ date: Date?) -> String {
        guard let date else {
            return L10n.string("common.unknown", default: "Unknown")
        }
        return date.formatted(.dateTime.month(.wide).day().year())
    }

    static func cycleLengthText(_ cycleLength: Int16) -> String {
        L10n.format("common.days_format", default: "%d days", Int(cycleLength))
    }

    static func periodLengthText(_ periodLength: Int16) -> String {
        L10n.format("insights.history.period_days_format", default: "%d days period", Int(periodLength))
    }
}
