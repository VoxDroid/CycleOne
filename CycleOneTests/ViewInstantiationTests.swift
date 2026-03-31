import CoreData
@testable import CycleOne
import SwiftUI
import UIKit
import XCTest

final class ViewInstantiationTests: XCTestCase {
    // Use the shared `host(_:context:)` helper from CycleOneTests/Helpers/ViewTestHelpers.swift

    func testOnboardingTipView_body_builds() {
        let view = OnboardingTipView(onDismiss: {})
        host(view)
    }

    func testEmptyStateView_body_builds() {
        let view = EmptyStateView(icon: "xmark.circle", title: "No Data", message: "Please add data")
        host(view)
    }

    func testPillBadge_body_builds() {
        let view = PillBadge(text: "New", color: .themeAccent)
        host(view)
    }

    func testPhaseIndicator_body_builds() {
        let view = PhaseIndicator(phase: "Fertile", color: .green)
        host(view)
    }

    func testCycleComparisonView_body_builds_withCycles() {
        let context = TestPersistenceController.empty().container.viewContext
        let start = Date().startOfDay

        let c1 = Cycle(context: context)
        c1.startDate = start
        c1.cycleLength = 28
        c1.periodLength = 5

        let c2 = Cycle(context: context)
        c2.startDate = Calendar.current.date(byAdding: .day, value: -30, to: start)
        c2.cycleLength = 30
        c2.periodLength = 5

        let view = CycleComparisonView(cycles: [c1, c2])
        host(view)
    }

    func testInsightsComponents_and_stat_views_build() throws {
        let data: [(date: Date, length: Int)] = try [
            (date: Date().startOfDay, length: 28),
            (date: XCTUnwrap(Calendar.current.date(byAdding: .day, value: -28, to: Date().startOfDay)), length: 30),
        ]
        host(CycleLengthChartView(data: data))

        host(StatCard(icon: "star", title: "Avg", value: "28", unit: "d", color: .themeAccent))

        host(MiniStatCard(title: "Short", value: "24", icon: "arrow.down", color: .green))

        host(MoodDistributionView(distribution: ["Happy": 3, "Sad": 1]))

        host(SymptomBreakdownView(symptoms: [("Cramps", 5), ("Bloating", 3)]))
    }

    func testMainAndSettingsRelated_views_build() {
        let context = TestPersistenceController.empty().container.viewContext

        host(MainTabView())
        host(AboutView())
        host(PrivacyPolicyView())
        host(HelpView())

        host(SettingsRow(icon: "gear", title: "T", subtitle: "s", color: .themeAccent, showChevron: true))

        host(SettingsView())
        host(NotificationSettingsView())
        host(ExportView())
        host(AboutView())

        host(InsightsView(context: context), context: context)
    }

    func testHistory_and_comparison_views_build() {
        let context = TestPersistenceController.empty().container.viewContext
        let c1 = Cycle(context: context)
        c1.startDate = Date().startOfDay
        c1.cycleLength = 28

        let c2 = Cycle(context: context)
        c2.startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date().startOfDay)
        c2.cycleLength = 30

        host(CycleHistoryList(cycles: [c1, c2]))
    }

    func test_log_and_form_related_views_build() {
        let context = TestPersistenceController.empty().container.viewContext

        host(FlowPickerView(selection: .constant(.medium)))

        host(SymptomGridView(selectedSymptoms: .constant([]), symptoms: SymptomType.defaults))
        host(SymptomChip(name: "sym", isSelected: false, action: {}))

        let date = Date().startOfDay
        host(LogView(date: date, context: context), context: context)
    }

    func test_calendar_views_build() {
        let context = TestPersistenceController.empty().container.viewContext

        host(CalendarView(context: context), context: context)
        host(CalendarLegendView())
        host(CycleHeaderView(daysUntilPeriod: 3, daysUntilOvulation: 10, isIrregular: false))

        let status = DayStatus(flow: .light, isPredicted: false, isOvulation: false, isFertile: false, hasLogs: true)
        host(CalendarDayCell(date: Date(), status: status, isToday: true, isSelected: false))

        // CalendarDayDetailView with and without a DayLog
        let log = DayLog(context: context)
        log.id = UUID()
        log.date = Date().startOfDay
        log.flowLevel = FlowLevel.light.rawValue
        log.mood = Mood.happy.rawValue

        host(CalendarDayDetailView(date: Date(), log: log, onLog: {}), context: context)
        host(CalendarDayDetailView(date: Date(), log: nil, onLog: {}), context: context)
    }
}
