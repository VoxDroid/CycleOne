//
//  CalendarView.swift
//  CycleOne
//

import CoreData
import SwiftUI

struct CalendarView: View {
    @Environment(\.managedObjectContext) var context
    @StateObject private var viewModel: CycleViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage(AppLanguage.storageKey) private var selectedLanguageCode = AppLanguage.system.rawValue

    init(context: NSManagedObjectContext) {
        _viewModel = StateObject(
            wrappedValue: CycleViewModel(context: context)
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 0) {
                        CycleHeaderView(
                            daysUntilPeriod: viewModel.daysUntilPeriod,
                            daysUntilOvulation: viewModel.daysUntilOvulation,
                            isIrregular: viewModel.isIrregular
                        )
                        .padding()
                        .fadeSlideIn(delay: 0.1)

                        NativeCalendarView(
                            viewModel: viewModel,
                            selectedLanguageCode: selectedLanguageCode
                        )
                        .padding(.horizontal)
                        .frame(minHeight: 400)
                        .fadeSlideIn(delay: 0.2)

                        CalendarLegendView()
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .fadeSlideIn(delay: 0.3)

                        CalendarDayDetailView(
                            date: viewModel.selectedDate,
                            log: viewModel.selectedDayLog
                        )
                        .padding(.top)
                        .fadeSlideIn(delay: 0.35)

                        Spacer()
                    }
                }
                .navigationTitle("CycleOne")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: Date.self) { date in
                    LogView(date: date, context: context)
                        .environmentObject(themeManager)
                }

                if !hasSeenOnboarding {
                    OnboardingTipView {
                        withAnimation(
                            .spring(response: 0.4, dampingFraction: 0.8)
                        ) {
                            hasSeenOnboarding = true
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                }
            }
        }
        .id("calendar-stack-\(selectedLanguageCode)")
        .environment(
            \.locale,
            AppLanguage.fromStoredValue(selectedLanguageCode).locale
        )
    }
}
