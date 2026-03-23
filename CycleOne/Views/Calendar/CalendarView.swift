//
//  CalendarView.swift
//  CycleOne
//

import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: CycleViewModel
    @State private var selectedDate = Date()
    @State private var showingLogSheet = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header Banner
                predictionHeader

                // Calendar Grid Header Placeholder
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .overlay(
                    // Simple overlay to show the power of the ViewModel status
                    VStack {
                        let status = viewModel.status(for: selectedDate)
                        if status != .none {
                            Text(statusName(for: status))
                                .font(.caption.bold())
                                .foregroundColor(statusColor(for: status))
                                .padding(6)
                                .background(statusColor(for: status).opacity(0.1))
                                .cornerRadius(8)
                                .padding(.top, 40)
                        }
                    }, alignment: .topTrailing
                )

                Spacer()

                // Log Button
                Button(action: { showingLogSheet = true }, label: {
                    Label("Log Day", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(statusColor(for: viewModel.status(for: Date()))) // Dynamic color
                        .cornerRadius(12)
                })
                .accessibilityIdentifier("LogDayButton")
                .padding()
            }
            .navigationTitle("CycleOne")
            .sheet(isPresented: $showingLogSheet) {
                LogView(viewModel: viewModel, date: selectedDate)
            }
        }
    }

    private var predictionHeader: some View {
        VStack {
            if let days = viewModel.daysUntilNextPeriod {
                Text("\(days)")
                    .font(.system(size: 48, weight: .bold))
                Text("Days until next period")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                if viewModel.isFertileToday {
                    Text("Fertile Window")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.themeFertile)
                        .cornerRadius(8)
                        .padding(.top, 4)
                }
            } else {
                Text("Start logging to see predictions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.themePeriod.opacity(0.1))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private func statusName(for status: CycleViewModel.DayStatus) -> String {
        switch status {
        case .period: "Period"
        case .predictedPeriod: "Predicted Period"
        case .fertile: "Fertile"
        case .ovulation: "Ovulation"
        case .none: ""
        }
    }

    private func statusColor(for status: CycleViewModel.DayStatus) -> Color {
        switch status {
        case .period, .predictedPeriod: .themePeriod
        case .fertile: .themeFertile
        case .ovulation: .themeOvulation
        case .none: .themeAccent
        }
    }
}
