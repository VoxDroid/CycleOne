import CoreData
@testable import CycleOne
import SwiftUI
import XCTest

final class ViewBranchTests: XCTestCase {
    func testCycleComparisonView_showsEmptyStateWhenNotEnoughCycles() {
        host(CycleComparisonView(cycles: []))
    }

    func testCycleComparisonView_diffPositiveAndZero() {
        let context = TestPersistenceController.empty().container.viewContext

        let c1 = Cycle(context: context)
        c1.startDate = Date().startOfDay
        c1.cycleLength = 30
        c1.periodLength = 5

        let c2 = Cycle(context: context)
        c2.startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date().startOfDay)
        c2.cycleLength = 28
        c2.periodLength = 4

        // current (30) vs previous (28) -> positive diff
        host(CycleComparisonView(cycles: [c1, c2]), context: context)

        // zero diff case
        let c3 = Cycle(context: context)
        c3.startDate = Date().startOfDay
        c3.cycleLength = 28
        c3.periodLength = 5

        let c4 = Cycle(context: context)
        c4.startDate = Calendar.current.date(byAdding: .day, value: -28, to: Date().startOfDay)
        c4.cycleLength = 28
        c4.periodLength = 5

        host(CycleComparisonView(cycles: [c3, c4]), context: context)
    }

    func testCycleComparisonView_diffNegative() {
        let context = TestPersistenceController.empty().container.viewContext

        let c1 = Cycle(context: context)
        c1.startDate = Date().startOfDay
        c1.cycleLength = 26
        c1.periodLength = 4

        let c2 = Cycle(context: context)
        c2.startDate = Calendar.current.date(byAdding: .day, value: -26, to: Date().startOfDay)
        c2.cycleLength = 30
        c2.periodLength = 6

        // current (26) vs previous (30) -> negative diff
        host(CycleComparisonView(cycles: [c1, c2]), context: context)
    }

    func testCalendarDayCell_branchVariants() {
        // Fill + today ring path
        let periodStatus = DayStatus(
            flow: .light,
            isPredicted: false,
            isOvulation: false,
            isFertile: false,
            hasLogs: false
        )
        host(CalendarDayCell(date: Date().startOfDay, status: periodStatus, isToday: true, isSelected: false))

        // Dot + selected outline path (no fill)
        let logDotStatus = DayStatus(
            flow: .none,
            isPredicted: false,
            isOvulation: false,
            isFertile: false,
            hasLogs: true
        )
        host(CalendarDayCell(date: Date().startOfDay, status: logDotStatus, isToday: false, isSelected: true))

        // Predicted fill path
        let predictedStatus = DayStatus(
            flow: .none,
            isPredicted: true,
            isOvulation: false,
            isFertile: true,
            hasLogs: false
        )
        host(CalendarDayCell(date: Date().startOfDay, status: predictedStatus, isToday: false, isSelected: false))
    }

    func testSettingsRow_branchVariants() {
        host(SettingsRow(icon: "gear", title: "Row A", subtitle: nil, color: .themeAccent, showChevron: false))
        host(SettingsRow(icon: "bell", title: "Row B", subtitle: "Subtitle", color: .themeAccent, showChevron: true))
    }

    func testNotificationSettingsView_periodPickerBranch() {
        let defaults = UserDefaults.standard
        let previousPeriod = defaults.object(forKey: "remindBeforePeriod")
        let previousFertile = defaults.object(forKey: "remindBeforeFertile")
        let previousDays = defaults.object(forKey: "daysBeforePeriod")

        defer {
            if let previousPeriod {
                defaults.set(previousPeriod, forKey: "remindBeforePeriod")
            } else {
                defaults.removeObject(forKey: "remindBeforePeriod")
            }
            if let previousFertile {
                defaults.set(previousFertile, forKey: "remindBeforeFertile")
            } else {
                defaults.removeObject(forKey: "remindBeforeFertile")
            }
            if let previousDays {
                defaults.set(previousDays, forKey: "daysBeforePeriod")
            } else {
                defaults.removeObject(forKey: "daysBeforePeriod")
            }
        }

        defaults.set(true, forKey: "remindBeforePeriod")
        defaults.set(true, forKey: "remindBeforeFertile")
        defaults.set(5, forKey: "daysBeforePeriod")

        host(NotificationSettingsView())
    }

    func testPrivacyPolicyAndWebView_buildPaths() throws {
        host(PrivacyPolicyView())
        try host(WebView(url: XCTUnwrap(URL(string: "https://example.com/privacy"))))
    }
}
