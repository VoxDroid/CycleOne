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
                        current: pair.current.startDate?
                            .formatted(
                                .dateTime.month(.abbreviated)
                                    .day()
                            ) ?? "N/A",
                        previous: pair.previous.startDate?
                            .formatted(
                                .dateTime.month(.abbreviated)
                                    .day()
                            ) ?? "N/A"
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
            } else {
                EmptyStateView(
                    icon: "arrow.left.arrow.right",
                    title: "Not Enough Data",
                    message: "Log at least two cycles to compare."
                )
                .padding(.top, 60)
            }
        }
        .accessibilityIdentifier("CycleComparisonViewRoot")
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Compare Cycles")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct ComparisonRow: View {
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
                            systemName: diff > 0
                                ? "arrow.up.circle.fill"
                                : diff < 0
                                ? "arrow.down.circle.fill"
                                : "equal.circle.fill"
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
                        diff > 0
                            ? .orange
                            : diff < 0 ? .green : .secondary
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
}
