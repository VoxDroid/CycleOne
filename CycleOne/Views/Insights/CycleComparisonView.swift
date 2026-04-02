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
                    Text("Cycle Comparison")
                        .font(.headline)
                        .foregroundColor(.themeAccent)
                        .padding(.top, 8)

                    HStack(spacing: 0) {
                        Text("Current")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.themeAccent)
                            .frame(maxWidth: .infinity)

                        Text("vs")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("Previous")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal)

                    ComparisonRow(
                        label: "Start Date",
                        current: Self.formattedStartDate(pair.current.startDate),
                        previous: Self.formattedStartDate(pair.previous.startDate)
                    )

                    ComparisonRow(
                        label: "Cycle Length",
                        current: "\(pair.current.cycleLength) days",
                        previous: "\(pair.previous.cycleLength) days",
                        diff: Int(pair.current.cycleLength)
                            - Int(pair.previous.cycleLength)
                    )

                    ComparisonRow(
                        label: "Period Length",
                        current: "\(pair.current.periodLength) days",
                        previous: "\(pair.previous.periodLength) days",
                        diff: Int(pair.current.periodLength)
                            - Int(pair.previous.periodLength)
                    )

                    // Visual bar comparison
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Length Comparison")
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
                                Text("Current")
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
                                Text("Previous")
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
        .navigationTitle("Compare Cycles")
        .navigationBarTitleDisplayMode(.inline)
    }

    static func formattedStartDate(_ date: Date?) -> String {
        date?.formatted(
            .dateTime.month(.abbreviated)
                .day()
        ) ?? "N/A"
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
            title: "Not Enough Data",
            message: "Log at least two cycles to compare."
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
    let label: String
    let current: String
    let previous: String
    var diff: Int?

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
                        Text(
                            diff == 0
                                ? "Same"
                                : "\(abs(diff))d"
                        )
                        .font(.caption2)
                        .fontWeight(.medium)
                    }
                    .foregroundColor(
                        Self.diffColor(for: diff)
                    )
                } else {
                    Text("vs")
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
