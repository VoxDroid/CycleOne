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

                // Calendar Grid Placeholder
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()

                Spacer()

                // Log Button
                Button(action: { showingLogSheet = true }, label: {
                    Label("Log Day", systemImage: "plus.circle.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.pink)
                        .cornerRadius(12)
                })
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
            } else {
                Text("Start logging to see predictions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.pink.opacity(0.1))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
