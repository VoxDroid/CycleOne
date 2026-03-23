//
//  InsightsView.swift
//  CycleOne
//
//  Created by Antigravity on 3/23/26.
//

import SwiftUI

struct InsightsView: View {
    @StateObject private var viewModel = InsightsViewModel()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Stats Grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(title: "Avg. Cycle", value: "\(viewModel.averageCycleLength)", unit: "days")
                        StatCard(title: "Avg. Period", value: "\(viewModel.averagePeriodLength)", unit: "days")
                    }
                    .padding(.horizontal)

                    // Symptoms Section
                    VStack(alignment: .leading) {
                        Text("Top Symptoms (Last 30 Days)")
                            .font(.headline)
                            .padding(.horizontal)

                        if viewModel.topSymptoms.isEmpty {
                            Text("No symptoms logged recently")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(viewModel.topSymptoms, id: \.self) { symptom in
                                        Text(symptom)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 8)
                                            .background(Color.pink.opacity(0.1))
                                            .cornerRadius(20)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // History Section
                    VStack(alignment: .leading) {
                        Text("Cycle History")
                            .font(.headline)
                            .padding(.horizontal)

                        if viewModel.cycleHistory.isEmpty {
                            ContentUnavailableView("No cycles logged", systemImage: "calendar.badge.exclamationmark")
                                .padding()
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.cycleHistory) { cycle in
                                    CycleHistoryRow(cycle: cycle)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Insights")
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                Text(unit)
                    .font(.caption.bold())
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct CycleHistoryRow: View {
    let cycle: Cycle

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(cycle.startDate?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown")
                    .font(.headline)
                Text("\(cycle.cycleLength) days total")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text("\(cycle.periodLength)d")
                .font(.subheadline.bold())
                .foregroundColor(.pink)
                .padding(8)
                .background(Color.pink.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}
