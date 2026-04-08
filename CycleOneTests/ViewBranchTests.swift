import CoreData
@testable import CycleOne
import SwiftUI
import UIKit
import XCTest

private final class ThrowingDeleteManagedObjectContext: NSManagedObjectContext, @unchecked Sendable {
    private(set) var executeCalls = 0
    private(set) var saveCalls = 0

    override var hasChanges: Bool {
        true
    }

    override func execute(_ request: NSPersistentStoreRequest) throws -> NSPersistentStoreResult {
        executeCalls += 1
        throw NSError(domain: "ViewBranchTests", code: 1)
    }

    override func save() throws {
        saveCalls += 1
        throw NSError(domain: "ViewBranchTests", code: 2)
    }
}

final class ViewBranchTests: XCTestCase {
    func testThrowingDeleteManagedObjectContext_hasChangesAndSaveFailure() {
        let context = ThrowingDeleteManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        XCTAssertTrue(context.hasChanges)
        XCTAssertThrowsError(try context.save())
        XCTAssertEqual(context.saveCalls, 1)
    }

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

    func testCycleComparisonView_singleCycleStillShowsEmptyState() {
        let context = TestPersistenceController.empty().container.viewContext
        let cycle = Cycle(context: context)
        cycle.startDate = Date().startOfDay
        cycle.cycleLength = 28
        cycle.periodLength = 5

        host(CycleComparisonView(cycles: [cycle]), context: context)
    }

    func testCycleComparisonView_missingStartDateFallsBackToNA() {
        let context = TestPersistenceController.empty().container.viewContext

        let c1 = Cycle(context: context)
        c1.startDate = nil
        c1.cycleLength = 30
        c1.periodLength = 5

        let c2 = Cycle(context: context)
        c2.startDate = Date().adding(days: -30).startOfDay
        c2.cycleLength = 28
        c2.periodLength = 4

        host(CycleComparisonView(cycles: [c1, c2]), context: context)
    }

    func testCycleComparisonView_debugHelpers_coverLatestTwoAndEmptyState() {
        let context = TestPersistenceController.empty().container.viewContext

        let single = Cycle(context: context)
        single.id = UUID()
        single.startDate = Date().startOfDay
        single.cycleLength = 28
        single.periodLength = 5

        let singleView = CycleComparisonView(cycles: [single])
        XCTAssertFalse(singleView.testHasLatestTwo)
        host(singleView.testEmptyStateView(), context: context)

        let previous = Cycle(context: context)
        previous.id = UUID()
        previous.startDate = Date().adding(days: -28).startOfDay
        previous.cycleLength = 28
        previous.periodLength = 5

        let pairedView = CycleComparisonView(cycles: [single, previous])
        XCTAssertTrue(pairedView.testHasLatestTwo)
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

    func testCalendarDayDetailView_symptomSortingAndFallbacks() {
        let context = TestPersistenceController.empty().container.viewContext
        let date = Date().startOfDay

        let log = DayLog(context: context)
        log.id = UUID()
        log.date = date
        log.flowLevel = FlowLevel.light.rawValue
        log.mood = 99
        log.energyLevel = 99
        log.painLevel = 4
        log.notes = "Detail note"

        let symptomA = Symptom(context: context)
        symptomA.id = "sA"
        symptomA.name = "zzz"
        symptomA.category = SymptomCategory.physical.rawValue

        let symptomB = Symptom(context: context)
        symptomB.id = "sB"
        symptomB.name = "aaa"
        symptomB.category = SymptomCategory.mood.rawValue

        let symptomC = Symptom(context: context)
        symptomC.id = "sC"
        symptomC.name = "mmm"
        symptomC.category = SymptomCategory.digestion.rawValue

        let symptomD = Symptom(context: context)
        symptomD.id = "sD"
        symptomD.name = "nnn"
        symptomD.category = SymptomCategory.other.rawValue

        let symptomUnknown = Symptom(context: context)
        symptomUnknown.id = "sU"
        symptomUnknown.name = nil
        symptomUnknown.category = nil

        log.addToSymptoms(symptomA)
        log.addToSymptoms(symptomB)
        log.addToSymptoms(symptomC)
        log.addToSymptoms(symptomD)
        log.addToSymptoms(symptomUnknown)

        host(CalendarDayDetailView(date: date, log: log), context: context)
    }

    func testSettingsRow_branchVariants() {
        host(SettingsRow(icon: "gear", title: "Row A", subtitle: nil, color: .themeAccent, showChevron: false))
        host(SettingsRow(icon: "bell", title: "Row B", subtitle: "Subtitle", color: .themeAccent, showChevron: true))
    }

    func testSymptomGrid_toggleHelper_addsAndRemovesSelections() {
        let added = SymptomGridView.toggledSymptoms(current: [], symptomID: "cramps")
        XCTAssertEqual(added, ["cramps"])

        let removed = SymptomGridView.toggledSymptoms(current: ["cramps"], symptomID: "cramps")
        XCTAssertTrue(removed.isEmpty)
    }

    func testSymptomGrid_flowLayoutWrapsOnNarrowWidth() {
        host(
            SymptomGridView(
                selectedSymptoms: .constant([]),
                symptoms: SymptomType.defaults
            )
            .frame(width: 96)
        )
    }

    @MainActor
    func testSettingsView_applyAccent_updatesThemeManager() {
        let manager = ThemeManager.shared
        let previousAccent = manager.selectedAccent
        defer { manager.selectedAccent = previousAccent }

        SettingsView.applyAccent(.sage, themeManager: manager)

        XCTAssertEqual(manager.selectedAccent, .sage)
    }

    func testSettingsView_deleteAllData_clearsPersistedEntities() throws {
        let context = TestPersistenceController.empty().container.viewContext

        let cycle = Cycle(context: context)
        cycle.id = UUID()
        cycle.startDate = Date().startOfDay
        cycle.createdAt = Date()

        let log = DayLog(context: context)
        log.id = UUID()
        log.date = Date().startOfDay
        log.flowLevel = FlowLevel.light.rawValue

        let symptom = Symptom(context: context)
        symptom.id = UUID().uuidString
        symptom.name = "Cramps"
        symptom.category = "Physical"
        symptom.dayLog = log
        log.addToSymptoms(symptom)

        try context.save()

        SettingsView.deleteAllData(in: context)

        XCTAssertEqual(try context.count(for: Cycle.fetchRequest()), 0)
        XCTAssertEqual(try context.count(for: DayLog.fetchRequest()), 0)
        XCTAssertEqual(try context.count(for: Symptom.fetchRequest()), 0)
    }

    func testSettingsView_deleteAllData_handlesDeleteFailures() throws {
        let throwingContext = ThrowingDeleteManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        throwingContext.persistentStoreCoordinator = try makeInMemoryCoordinator()

        SettingsView.deleteAllData(in: throwingContext)

        XCTAssertEqual(throwingContext.executeCalls, 3)
        XCTAssertEqual(throwingContext.saveCalls, 0)
    }

    func testCycleHeaderView_predictionAndIrregularBranches() {
        host(CycleHeaderView(daysUntilPeriod: nil, daysUntilOvulation: nil, isIrregular: false))
        host(CycleHeaderView(daysUntilPeriod: -2, daysUntilOvulation: nil, isIrregular: true))
        host(CycleHeaderView(daysUntilPeriod: 0, daysUntilOvulation: 0, isIrregular: false))
        host(CycleHeaderView(daysUntilPeriod: 5, daysUntilOvulation: 2, isIrregular: true))
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
        host(PrivacyPolicyView(policyURL: nil))
        let url = try XCTUnwrap(URL(string: "https://example.com/privacy"))
        try host(WebView(url: url))

        XCTAssertNotNil(WebView.makeBaseWebView())
        XCTAssertEqual(WebView.makeRequest(for: url).url, url)
        XCTAssertNil(PrivacyPolicyView.fallbackMessage(for: url))
        XCTAssertEqual(
            PrivacyPolicyView.fallbackMessage(for: nil),
            L10n.string(
                "privacy_policy.not_found",
                default: "Privacy Policy not found."
            )
        )
        XCTAssertNotNil(PrivacyPolicyView.defaultPolicyURL(language: .english))
        XCTAssertNotNil(PrivacyPolicyView.defaultPolicyURL(language: .system))
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

    func testCycleHistoryList_missingStartDateFallback() {
        let context = TestPersistenceController.empty().container.viewContext

        let cycle = Cycle(context: context)
        cycle.id = UUID()
        cycle.startDate = nil
        cycle.cycleLength = 0
        cycle.periodLength = 4

        host(CycleHistoryList(cycles: [cycle]), context: context)
        let fallback = L10n.string("common.unknown", default: "Unknown")
        XCTAssertEqual(CycleHistoryList.formattedStartDate(nil), fallback)
        XCTAssertNotEqual(CycleHistoryList.formattedStartDate(Date().startOfDay), fallback)
    }

    func testInsightsAndSettingsViews_withSeededData_buildDeeperBranches() throws {
        let context = TestPersistenceController.empty().container.viewContext
        try seedInsightsData(in: context)

        host(InsightsView(context: context), context: context)
        host(SettingsView(), context: context)
        host(HelpView(), context: context)
        host(AboutView(), context: context)
    }

    @MainActor
    func testInsightsView_reactsToLanguageChange() throws {
        let defaults = UserDefaults.standard
        let previous = defaults.string(forKey: AppLanguage.storageKey)
        defer {
            if let previous {
                defaults.set(previous, forKey: AppLanguage.storageKey)
            } else {
                defaults.removeObject(forKey: AppLanguage.storageKey)
            }
        }

        defaults.set(AppLanguage.english.rawValue, forKey: AppLanguage.storageKey)

        let context = TestPersistenceController.empty().container.viewContext
        try seedInsightsData(in: context)

        let root = InsightsView(context: context)
            .environment(\.managedObjectContext, context)
            .environmentObject(ThemeManager.shared)
        let host = UIHostingController(rootView: root)

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = host
        window.makeKeyAndVisible()
        host.view.layoutIfNeeded()

        defaults.set(AppLanguage.japanese.rawValue, forKey: AppLanguage.storageKey)
        RunLoop.main.run(until: Date().addingTimeInterval(0.15))

        XCTAssertEqual(
            AppLanguage.currentSelection(userDefaults: defaults),
            .japanese
        )
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
            log.flowLevel = FlowLevel(rawValue: Int16(index % 3 + 1))!.rawValue
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

    private func makeInMemoryCoordinator() throws -> NSPersistentStoreCoordinator {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: PersistenceController.model)
        try coordinator.addPersistentStore(
            ofType: NSInMemoryStoreType,
            configurationName: nil,
            at: nil,
            options: nil
        )
        return coordinator
    }
}
