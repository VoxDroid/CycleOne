//
//  CycleComparisonView.swift
//  CycleOne
//

import SwiftUI

struct CycleComparisonView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let cycles: [Cycle]

    private var latestTwo: (current: Cycle, previous: Cycle)? {
        guard cycles.count >= 2 else { return nil }
        return (current: cycles[0], previous: cycles[1])
    }

    var body: some View {
        ScrollView {
            if let pair = latestTwo {
                VStack(spacing: 16) {
                    Text("insights.compare.title")
                        .font(.headline)
                        .foregroundColor(.themeAccent)
                        .padding(.top, 8)

                    HStack(spacing: 0) {
                        Text("insights.compare.current")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.themeAccent)
                            .frame(maxWidth: .infinity)

                        Text("common.vs")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("insights.compare.previous")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)

                    ComparisonRow(
                        label: "insights.compare.start_date",
                        current: Self.formattedStartDate(pair.current.startDate),
                        previous: Self.formattedStartDate(pair.previous.startDate)
                    )

                    ComparisonRow(
                        label: "insights.compare.cycle_length",
                        current: Self.daysText(Int(pair.current.cycleLength)),
                        previous: Self.daysText(Int(pair.previous.cycleLength)),
                        diff: Int(pair.current.cycleLength)
                            - Int(pair.previous.cycleLength)
                    )

                    ComparisonRow(
                        label: "insights.compare.period_length",
                        current: Self.daysText(Int(pair.current.periodLength)),
                        previous: Self.daysText(Int(pair.previous.periodLength)),
                        diff: Int(pair.current.periodLength)
                            - Int(pair.previous.periodLength)
                    )

                    // Visual bar comparison
                    VStack(alignment: .leading, spacing: 8) {
                        Text("insights.compare.length_comparison")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)

                        let maxLen = max(
                            Int(pair.current.cycleLength),
                            Int(pair.previous.cycleLength),
                            1
                        )

                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Text("insights.compare.current")
                                    .font(.caption)
                                    .frame(
                                        width: 60,
                                        alignment: .leading
                                    )
                                GeometryReader { geo in
                                    RoundedRectangle(
                                        cornerRadius: 4
                                    )
                                    .fill(Color.themeAccent)
                                    .frame(
                                        width: geo.size
                                            .width
                                            * CGFloat(
                                                pair.current
                                                    .cycleLength
                                            )
                                            / CGFloat(maxLen)
                                    )
                                }
                                .frame(height: 20)
                            }

                            HStack(spacing: 8) {
                                Text("insights.compare.previous")
                                    .font(.caption)
                                    .frame(
                                        width: 60,
                                        alignment: .leading
                                    )
                                GeometryReader { geo in
                                    RoundedRectangle(
                                        cornerRadius: 4
                                    )
                                    .fill(
                                        Color.secondary
                                            .opacity(0.5)
                                    )
                                    .frame(
                                        width: geo.size
                                            .width
                                            * CGFloat(
                                                pair.previous
                                                    .cycleLength
                                            )
                                            / CGFloat(maxLen)
                                    )
                                }
                                .frame(height: 20)
                            }
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(
                            cornerRadius: Theme.cornerRadius
                        )
                        .fill(Color(.secondarySystemBackground))
                    )
                    .padding(.horizontal)
                }
                .padding(.bottom, 24)
            }

            emptyStateView
                .opacity(Self.emptyStateOpacity(hasLatestTwo: latestTwo != nil))
                .frame(height: Self.emptyStateHeight(hasLatestTwo: latestTwo != nil))
        }
        .accessibilityIdentifier("CycleComparisonViewRoot")
        .background(Color(.systemGroupedBackground))
        .navigationTitle("insights.compare.navigation_title")
        .navigationBarTitleDisplayMode(.inline)
    }

    static func formattedStartDate(_ date: Date?) -> String {
        date?.formatted(
            .dateTime.month(.abbreviated)
                .day()
        ) ?? L10n.string("common.na", default: "N/A")
    }

    static func daysText(_ days: Int) -> String {
        L10n.format("common.days_format", default: "%d days", days)
    }

    static func emptyStateOpacity(hasLatestTwo: Bool) -> Double {
        hasLatestTwo ? 0 : 1
    }

    static func emptyStateHeight(hasLatestTwo: Bool) -> CGFloat? {
        hasLatestTwo ? 0 : nil
    }

    private var emptyStateView: some View {
        EmptyStateView(
            icon: "arrow.left.arrow.right",
            title: "insights.compare.empty_title",
            message: "insights.compare.empty_message"
        )
        .padding(.top, 60)
    }

    #if DEBUG
        var testHasLatestTwo: Bool {
            latestTwo != nil
        }

        func testEmptyStateView() -> some View {
            emptyStateView
        }
    #endif
}

struct ComparisonRow: View {
    let label: LocalizedStringKey
    let current: String
    let previous: String
    var diff: Int?

    init(
        label: String,
        current: String,
        previous: String,
        diff: Int? = nil
    ) {
        self.label = LocalizedStringKey(label)
        self.current = current
        self.previous = previous
        self.diff = diff
    }

    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(spacing: 0) {
                Text(current)
                    .font(.system(
                        .body, design: .rounded
                    ))
                    .fontWeight(.semibold)
                    .foregroundColor(.themeAccent)
                    .frame(maxWidth: .infinity)

                if let diff {
                    HStack(spacing: 2) {
                        Image(
                            systemName: Self.diffIconName(for: diff)
                        )
                        .font(.caption2)
                        Text(Self.diffText(for: diff))
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(
                        Self.diffColor(for: diff)
                    )
                } else {
                    Text("common.vs")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Text(previous)
                    .font(.system(
                        .body, design: .rounded
                    ))
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.horizontal)
    }

    static func diffIconName(for diff: Int) -> String {
        switch diff {
        case let value where value > 0:
            "arrow.up.circle.fill"
        case let value where value < 0:
            "arrow.down.circle.fill"
        default:
            "equal.circle.fill"
        }
    }

    static func diffText(for diff: Int) -> String {
        if diff == 0 {
            return L10n.string("common.same", default: "Same")
        }

        return L10n.format("common.days_short_format", default: "%dd", abs(diff))
    }

    static func diffColor(for diff: Int) -> Color {
        switch diff {
        case let value where value > 0:
            .orange
        case let value where value < 0:
            .green
        default:
            .secondary
        }
    }
}
