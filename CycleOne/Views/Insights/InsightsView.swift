//
//  InsightsView.swift
//  CycleOne
//

import CoreData
import SwiftUI

struct InsightsView: View {
    @Environment(\.managedObjectContext) var context
    @StateObject private var viewModel: InsightsViewModel

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: InsightsViewModel(context: context))
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Summary") {
                    HStack {
                        StatBox(title: "Avg Cycle", value: "\(Int(viewModel.avgCycleLength)) days")
                        StatBox(title: "Avg Period", value: "\(Int(viewModel.avgPeriodLength)) days")
                    }
                    .listRowInsets(EdgeInsets())
                    .padding()
                }

                Section("Variation") {
                    HStack {
                        StatBox(title: "Shortest", value: "\(viewModel.shortestCycle)d")
                        StatBox(title: "Longest", value: "\(viewModel.longestCycle)d")
                    }
                    .listRowInsets(EdgeInsets())
                    .padding()
                }

                if !viewModel.topSymptoms.isEmpty {
                    Section("Top Symptoms") {
                        ForEach(viewModel.topSymptoms, id: \.self) { symptom in
                            Text(symptom)
                        }
                    }
                }

                Section {
                    NavigationLink(destination: CycleHistoryList(cycles: viewModel.recentCycles)) {
                        Label("View Full History", systemImage: "clock.arrow.circlepath")
                    }
                }
            }
            .navigationTitle("Insights")
            .onAppear {
                viewModel.calculateStats()
            }
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}
