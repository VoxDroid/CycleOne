import CoreData
@testable import CycleOne
import XCTest

final class CycleViewModelTests: XCTestCase {
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
}
