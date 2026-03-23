//
//  CalendarView.swift
//  CycleOne
//

import CoreData
import SwiftUI

struct CalendarView: View {
    @Environment(\.managedObjectContext) var context
    @StateObject private var viewModel: CycleViewModel
    @State private var showingLogSheet = false

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: CycleViewModel(context: context))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Prediction Banner
                CycleHeaderView(
                    daysUntilPeriod: viewModel.daysUntilPeriod,
                    isIrregular: viewModel.isIrregular
                )
                .padding()

                // Month Header
                HStack {
                    Text(viewModel.currentMonth.formatted(.dateTime.month(.wide).year()))
                        .font(.headline)
                    Spacer()
                    HStack(spacing: 20) {
                        Button(action: viewModel.previousMonth) {
                            Image(systemName: "chevron.left")
                        }
                        Button(action: viewModel.nextMonth) {
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Calendar Grid
                CalendarGridView(
                    month: viewModel.currentMonth,
                    selectedDate: $viewModel.selectedDate,
                    dayStatuses: viewModel.dayStatuses
                )
                .padding(.horizontal)

                Spacer()

                // Log Button
                Button(action: { showingLogSheet = true }, label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Log \(viewModel.selectedDate.formatted(date: .abbreviated, time: .omitted))")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.themeAccent)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                })
                .padding()
                .accessibilityIdentifier("LogDayButton")
            }
            .navigationTitle("CycleOne")
            .sheet(isPresented: $showingLogSheet) {
                LogView(date: viewModel.selectedDate, context: context)
            }
        }
    }
}

struct CalendarGridView: View {
    let month: Date
    @Binding var selectedDate: Date
    let dayStatuses: [Date: DayStatus]

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(daysInMonth(), id: \.self) { date in
                if let date {
                    CalendarDayCell(
                        date: date,
                        status: dayStatuses[date.startOfDay] ?? DayStatus(),
                        isToday: date.isSameDay(as: Date()),
                        isSelected: date.isSameDay(as: selectedDate)
                    )
                    .onTapGesture {
                        selectedDate = date
                    }
                } else {
                    Color.clear
                        .aspectRatio(1, contentMode: .fill)
                }
            }
        }
    }

    private func daysInMonth() -> [Date?] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: month) else { return [] }
        let firstDayOfMonth = monthInterval.start
        let weekday = Calendar.current.component(.weekday, from: firstDayOfMonth)
        let offset = (weekday - Calendar.current.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: offset)

        guard let range = Calendar.current.range(of: .day, in: .month, for: month) else { return days }
        for day in 1 ... range.count {
            if let date = Calendar.current.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }

        return days
    }
}
