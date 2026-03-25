//
//  CalendarView.swift
//  CycleOne
//

import CoreData
import SwiftUI

struct CalendarView: View {
    @Environment(\.managedObjectContext) var context
    @StateObject private var viewModel: CycleViewModel
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(wrappedValue: CycleViewModel(context: context))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 0) {
                        // Prediction Banner
                        CycleHeaderView(
                            daysUntilPeriod: viewModel.daysUntilPeriod,
                            daysUntilOvulation: viewModel.daysUntilOvulation,
                            isIrregular: viewModel.isIrregular
                        )
                        .padding()

                        // Native Calendar View
                        NativeCalendarView(viewModel: viewModel)
                            .padding(.horizontal)
                            .frame(minHeight: 400) // Ensure it has enough space

                        CalendarLegendView()
                            .padding(.horizontal)
                            .padding(.top, 8)

                        CalendarDayDetailView(
                            date: viewModel.selectedDate,
                            log: viewModel.selectedDayLog,
                            onLog: {} // Interaction handled by NavigationLink in detail view
                        )
                        .padding(.top)

                        Spacer()
                    }
                }
                .background(Color(.systemBackground))
                .navigationTitle("CycleOne")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: Date.self) { date in
                    LogView(date: date, context: context)
                }

                if !hasSeenOnboarding {
                    OnboardingTipView {
                        withAnimation {
                            hasSeenOnboarding = true
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
        }
    }
}
