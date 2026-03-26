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

                    // Top Symptoms
                    if !viewModel.topSymptoms.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Top Symptoms")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 4)

                            HStack(spacing: 8) {
                                ForEach(
                                    Array(
                                        viewModel.topSymptoms
                                            .enumerated()
                                    ),
                                    id: \.offset
                                ) { index, symptom in
                                    HStack(spacing: 6) {
                                        Image(
                                            systemName: medalIcon(
                                                for: index
                                            )
                                        )
                                        .font(.caption)
                                        .foregroundColor(
                                            medalColor(for: index)
                                        )
                                        Text(symptom)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        Color(
                                            .secondarySystemBackground
                                        )
                                    )
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .fadeSlideIn(delay: 0.3)
                    }

                    // History Link
                    NavigationLink(
                        destination: CycleHistoryList(
                            cycles: viewModel.recentCycles
                        )
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
                            Image(systemName: "chevron.right")
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
                    .fadeSlideIn(delay: 0.35)
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
