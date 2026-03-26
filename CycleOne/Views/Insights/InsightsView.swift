//
//  InsightsView.swift
//  CycleOne
//

import CoreData
import SwiftUI

struct InsightsView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var viewModel: InsightsViewModel

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(
            wrappedValue: InsightsViewModel(context: context)
        )
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Summary Cards
                    HStack(spacing: 12) {
                        StatCard(
                            icon: "calendar.circle.fill",
                            title: "Avg Cycle",
                            value: "\(Int(viewModel.avgCycleLength))",
                            unit: "days",
                            color: .themeAccent
                        )
                        .fadeSlideIn(delay: 0.05)

                        StatCard(
                            icon: "drop.fill",
                            title: "Avg Period",
                            value: "\(Int(viewModel.avgPeriodLength))",
                            unit: "days",
                            color: .themePeriod
                        )
                        .fadeSlideIn(delay: 0.1)
                    }
                    .padding(.horizontal)

                    // Variation Cards
                    HStack(spacing: 12) {
                        MiniStatCard(
                            title: "Shortest",
                            value: "\(viewModel.shortestCycle)d",
                            icon: "arrow.down.circle.fill",
                            color: .green
                        )
                        .fadeSlideIn(delay: 0.15)

                        MiniStatCard(
                            title: "Longest",
                            value: "\(viewModel.longestCycle)d",
                            icon: "arrow.up.circle.fill",
                            color: .orange
                        )
                        .fadeSlideIn(delay: 0.2)

                        MiniStatCard(
                            title: "Total",
                            value: "\(viewModel.totalCycles)",
                            icon: "number.circle.fill",
                            color: .themeAccent
                        )
                        .fadeSlideIn(delay: 0.25)
                    }
                    .padding(.horizontal)

                    // Extra Stats Row
                    HStack(spacing: 12) {
                        MiniStatCard(
                            title: "Avg Pain",
                            value: String(
                                format: "%.1f",
                                viewModel.avgPainLevel
                            ),
                            icon: "bolt.circle.fill",
                            color: .themePeriod
                        )
                        .fadeSlideIn(delay: 0.28)

                        MiniStatCard(
                            title: "Logged",
                            value: "\(viewModel.totalLogsCount)",
                            icon: "note.text",
                            color: .indigo
                        )
                        .fadeSlideIn(delay: 0.3)

                        MiniStatCard(
                            title: "Symptoms",
                            value: "\(viewModel.symptomDistribution.count)",
                            icon: "list.clipboard.fill",
                            color: .teal
                        )
                        .fadeSlideIn(delay: 0.32)
                    }
                    .padding(.horizontal)

                    // Cycle Length Trend Chart
                    if viewModel.cycleLengthHistory.count >= 2 {
                        CycleLengthChartView(
                            data: viewModel.cycleLengthHistory
                        )
                        .padding(.horizontal)
                        .fadeSlideIn(delay: 0.35)
                    }

                    // Mood Distribution
                    if !viewModel.moodDistribution.isEmpty {
                        MoodDistributionView(
                            distribution: viewModel
                                .moodDistribution
                        )
                        .padding(.horizontal)
                        .fadeSlideIn(delay: 0.38)
                    }

                    // Top Symptoms
                    if !viewModel.topSymptoms.isEmpty {
                        SymptomBreakdownView(
                            symptoms: viewModel
                                .symptomDistribution
                        )
                        .padding(.horizontal)
                        .fadeSlideIn(delay: 0.4)
                    }

                    // Cycle Comparison Link
                    if viewModel.recentCycles.count >= 2 {
                        NavigationLink(
                            destination: CycleComparisonView(
                                cycles: viewModel.recentCycles
                            )
                            .environmentObject(themeManager)
                        ) {
                            HStack {
                                Image(
                                    systemName:
                                    "arrow.left.arrow.right.circle.fill"
                                )
                                .foregroundColor(.themeAccent)
                                Text("Compare Cycles")
                                    .fontWeight(.medium)
                                Spacer()
                                Image(
                                    systemName: "chevron.right"
                                )
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(
                                Color(
                                    .secondarySystemBackground
                                )
                            )
                            .cornerRadius(Theme.cornerRadius)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                        .fadeSlideIn(delay: 0.42)
                    }

                    // History Link
                    NavigationLink(
                        destination: CycleHistoryList(
                            cycles: viewModel.recentCycles
                        )
                        .environmentObject(themeManager)
                    ) {
                        HStack {
                            Image(
                                systemName:
                                "clock.arrow.circlepath"
                            )
                            .foregroundColor(.themeAccent)
                            Text("View Full History")
                                .fontWeight(.medium)
                            Spacer()
                            Image(
                                systemName: "chevron.right"
                            )
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(
                            Color(.secondarySystemBackground)
                        )
                        .cornerRadius(Theme.cornerRadius)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    .fadeSlideIn(delay: 0.45)
                }
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.calculateStats()
            }
        }
    }
}

// MARK: - Cycle Length Trend Chart

struct CycleLengthChartView: View {
    let data: [(date: Date, length: Int)]

    private var maxLength: Int {
        data.map(\.length).max() ?? 35
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cycle Length Trend")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(
                    Array(data.suffix(8).enumerated()),
                    id: \.offset
                ) { _, entry in
                    VStack(spacing: 4) {
                        Text("\(entry.length)")
                            .font(.system(
                                size: 10,
                                design: .rounded
                            ))
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.themeAccent)
                            .frame(
                                height: CGFloat(
                                    entry.length
                                ) / CGFloat(maxLength)
                                    * 100
                            )

                        Text(
                            entry.date.formatted(
                                .dateTime.month(.narrow)
                            )
                        )
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 140)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Mood Distribution

struct MoodDistributionView: View {
    let distribution: [String: Int]

    private var total: Int {
        distribution.values.reduce(0, +)
    }

    private var sortedMoods: [(key: String, value: Int)] {
        distribution.sorted { $0.value > $1.value }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mood Overview")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            ForEach(sortedMoods, id: \.key) { mood in
                HStack(spacing: 8) {
                    Text(mood.key)
                        .font(.caption)
                        .frame(width: 60, alignment: .leading)

                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.themeAccent.opacity(0.7))
                            .frame(
                                width: total > 0
                                    ? geometry.size.width
                                    * CGFloat(mood.value)
                                    / CGFloat(total) : 0
                            )
                    }
                    .frame(height: 16)

                    Text("\(mood.value)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(width: 24, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Symptom Breakdown

struct SymptomBreakdownView: View {
    let symptoms: [(name: String, count: Int)]

    private var maxCount: Int {
        symptoms.map(\.count).max() ?? 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Top Symptoms")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            ForEach(
                Array(symptoms.prefix(5).enumerated()),
                id: \.offset
            ) { index, symptom in
                HStack(spacing: 8) {
                    Image(
                        systemName: medalIcon(for: index)
                    )
                    .font(.caption)
                    .foregroundColor(
                        medalColor(for: index)
                    )
                    .frame(width: 20)

                    Text(symptom.name)
                        .font(.caption)
                        .lineLimit(1)
                        .frame(
                            width: 80,
                            alignment: .leading
                        )

                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                medalColor(for: index)
                                    .opacity(0.6)
                            )
                            .frame(
                                width: geometry.size
                                    .width
                                    * CGFloat(
                                        symptom.count
                                    )
                                    / CGFloat(maxCount)
                            )
                    }
                    .frame(height: 14)

                    Text("\(symptom.count)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(width: 20, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private func medalIcon(for index: Int) -> String {
        switch index {
        case 0: "1.circle.fill"
        case 1: "2.circle.fill"
        case 2: "3.circle.fill"
        default: "circle.fill"
        }
    }

    private func medalColor(for index: Int) -> Color {
        switch index {
        case 0: .themeAccent
        case 1: .themeFertile
        case 2: .orange
        default: .secondary
        }
    }
}

// MARK: - Stat Cards

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(
                    alignment: .firstTextBaseline,
                    spacing: 4
                ) {
                    Text(value)
                        .font(.system(
                            size: 28, weight: .bold,
                            design: .rounded
                        ))
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Color(.secondarySystemBackground))
                .shadow(
                    color: color.opacity(0.08),
                    radius: 8, x: 0, y: 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}

struct MiniStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
