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
                        .accessibilityIdentifier("Insights_CompareCyclesLink")
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
                    .accessibilityIdentifier("Insights_HistoryLink")
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
