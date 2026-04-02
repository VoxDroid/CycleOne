import CoreData
@testable import CycleOne
import XCTest

final class CycleViewModelTests: XCTestCase {
    private final class SelectiveThrowManagedObjectContext: NSManagedObjectContext, @unchecked Sendable {
        var failingFetchEntities = Set<String>()

        override func execute(_ request: NSPersistentStoreRequest) throws -> NSPersistentStoreResult {
            if let fetchRequest = request as? NSFetchRequest<NSFetchRequestResult>,
               let entityName = fetchRequest.entityName,
               failingFetchEntities.contains(entityName)
            {
                throw NSError(
                    domain: "CycleViewModelTests",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Forced fetch failure for \(entityName)"]
                )
            }
            return try super.execute(request)
        }
    }

    var controller: PersistenceController!
    var context: NSManagedObjectContext {
        controller.container.viewContext
    }

    override func setUp() {
        super.setUp()
        controller = TestPersistenceController.empty()
    }

    override func tearDown() {
        controller = nil
        super.tearDown()
    }

    func testPredictionsAndDayStatuses() throws {
        // Create a cycle that started 28 days ago so predicted start is today
        let cycle = Cycle(context: context)
        cycle.id = UUID()
        cycle.startDate = Date().startOfDay.adding(days: -28)
        cycle.createdAt = Date()
        cycle.cycleLength = 28

        try context.save()

        let viewModel = CycleViewModel(context: context)

        // Predictions should be available
        XCTAssertNotNil(viewModel.daysUntilPeriod)

        // The predicted start should mark today as predicted
        let today = Date().startOfDay
        XCTAssertTrue(viewModel.dayStatuses[today]?.isPredicted == true)
    }

    func testSelectDateFetchesDayLog() throws {
        let date = Date().startOfDay
        let log = DayLog(context: context)
        log.id = UUID()
        log.date = date
        log.flowLevel = FlowLevel.none.rawValue

        try context.save()

        let viewModel = CycleViewModel(context: context)
        XCTAssertNotNil(viewModel.selectedDayLog)

        viewModel.selectDate(date)
        XCTAssertNotNil(viewModel.selectedDayLog)
        XCTAssertEqual(viewModel.selectedDayLog?.date?.startOfDay, date)
    }

    func testMonthNavigation() {
        let viewModel = CycleViewModel(context: context)
        let original = viewModel.currentMonth
        viewModel.nextMonth()
        XCTAssertNotEqual(viewModel.currentMonth, original)
        viewModel.previousMonth()
        XCTAssertEqual(viewModel.currentMonth, original)
    }

    func testRefreshData_whenPredictionsDisabled_setsNilPredictionState() {
        let defaults = UserDefaults.standard
        let previous = defaults.object(forKey: "enablePredictions")
        defaults.set(false, forKey: "enablePredictions")
        defer {
            if let previous {
                defaults.set(previous, forKey: "enablePredictions")
            } else {
                defaults.removeObject(forKey: "enablePredictions")
            }
        }

        let viewModel = CycleViewModel(context: context)
        viewModel.refreshData()

        XCTAssertNil(viewModel.daysUntilPeriod)
        XCTAssertNil(viewModel.daysUntilOvulation)
        XCTAssertFalse(viewModel.isIrregular)
    }

    func testRefreshData_handlesCycleFetchFailure() throws {
        let throwingContext = try makeThrowingContext(failingEntities: ["Cycle"])

        let viewModel = CycleViewModel(context: throwingContext)
        viewModel.refreshData()

        XCTAssertTrue(viewModel.dayStatuses.isEmpty)
    }

    func testGoTo_updatesCurrentMonthAndRefreshes() {
        let viewModel = CycleViewModel(context: context)
        let targetDate = Date().adding(days: 45).startOfDay

        viewModel.goTo(date: targetDate)

        XCTAssertEqual(viewModel.currentMonth, targetDate.startOfMonth)
    }

    func testRefreshData_invalidFlowMapsToNoneStatus() throws {
        let date = Date().startOfDay

        let log = DayLog(context: context)
        log.id = UUID()
        log.date = date
        log.flowLevel = 99

        try context.save()

        let viewModel = CycleViewModel(context: context)

        XCTAssertEqual(viewModel.dayStatuses[date]?.flow, FlowLevel.none)
    }

    private func makeThrowingContext(
        failingEntities: Set<String>
    ) throws -> NSManagedObjectContext {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: PersistenceController.model)
        try coordinator.addPersistentStore(
            ofType: NSInMemoryStoreType,
            configurationName: nil,
            at: nil,
            options: nil
        )

        let context = SelectiveThrowManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        context.failingFetchEntities = failingEntities
        return context
    }
}
