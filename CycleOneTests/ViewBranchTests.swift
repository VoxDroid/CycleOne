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

    func testCycleHistoryList_emptyAndPopulatedBranches() {
        let context = TestPersistenceController.empty().container.viewContext

        host(CycleHistoryList(cycles: []), context: context)

        let current = Cycle(context: context)
        current.startDate = Date().startOfDay
        current.cycleLength = 30
        current.periodLength = 5

        let previous = Cycle(context: context)
        previous.startDate = Date().adding(days: -30).startOfDay
        previous.cycleLength = 28
        previous.periodLength = 4

        host(CycleHistoryList(cycles: [current, previous]), context: context)
    }

    func testInsightsAndSettingsViews_withSeededData_buildDeeperBranches() throws {
        let context = TestPersistenceController.empty().container.viewContext
        try seedInsightsData(in: context)

        host(InsightsView(context: context), context: context)
        host(SettingsView(), context: context)
        host(HelpView(), context: context)
        host(AboutView(), context: context)
    }

    private func seedInsightsData(in context: NSManagedObjectContext) throws {
        let baseDate = Date().startOfDay
        let dates = [
            baseDate.adding(days: -56),
            baseDate.adding(days: -28),
            baseDate,
        ]

        for (index, date) in dates.enumerated() {
            let log = DayLog(context: context)
            log.id = UUID()
            log.date = date
            log.flowLevel = FlowLevel(rawValue: Int16(index % 3 + 1))?.rawValue ?? FlowLevel.light.rawValue
            log.mood = Mood.allCases[index % Mood.allCases.count].rawValue
            log.energyLevel = EnergyLevel.allCases[index % EnergyLevel.allCases.count].rawValue
            log.painLevel = Int16(index + 1)
            log.notes = "seed \(index)"

            let symptomType = SymptomType.defaults[index % SymptomType.defaults.count]
            let symptom = Symptom(context: context)
            symptom.id = symptomType.id
            symptom.name = symptomType.name
            symptom.category = symptomType.category.rawValue
            symptom.dayLog = log
            log.addToSymptoms(symptom)
        }

        try context.save()
        CycleManager.shared.fullSync(in: context)
    }
}
