//
//  CycleManagerTests.swift
//  CycleOneTests
//

import CoreData
@testable import CycleOne
import XCTest

final class CycleManagerTests: XCTestCase {
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

    func testRebuildAllCycles() throws {
        let calendar = Calendar(identifier: .gregorian)
        let date1 = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 1, day: 1))?.startOfDay)
        let date2Components = DateComponents(year: 2024, month: 1, day: 31)
        let date2 = try XCTUnwrap(calendar.date(from: date2Components)?.startOfDay)

        // 1. Create some flow logs using NSManagedObject directly
        let log1 = DayLog(context: context)
        log1.id = UUID()
        log1.date = date1
        log1.flowLevel = FlowLevel.medium.rawValue

        let log2 = DayLog(context: context)
        log2.id = UUID()
        log2.date = date2
        log2.flowLevel = FlowLevel.heavy.rawValue

        try context.save()

        let initialLogs = try context.fetch(DayLog.fetchRequest())
        XCTAssertEqual(initialLogs.count, 2, "Failed to persist 2 logs before rebuild")

        // 2. Rebuild
        CycleManager.shared.rebuildAllCycles(in: context)

        // 3. Verify cycles
        let request: NSFetchRequest<Cycle> = Cycle.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Cycle.startDate, ascending: true)]
        let cycles = try context.fetch(request)

        XCTAssertEqual(cycles.count, 2, "Expected 2 cycles but found \(cycles.count)")
        XCTAssertEqual(cycles[0].startDate?.startOfDay, date1.startOfDay)
        XCTAssertEqual(cycles[1].startDate?.startOfDay, date2.startOfDay)

        // Cycle 1 length: 30 days
        XCTAssertEqual(cycles[0].cycleLength, 30)

        // 4. Update a log to .none and rebuild
        log1.flowLevel = FlowLevel.none.rawValue
        try context.save()
        CycleManager.shared.rebuildAllCycles(in: context)

        let cyclesAfterDelete = try context.fetch(request)
        XCTAssertEqual(cyclesAfterDelete.count, 1)
        XCTAssertEqual(cyclesAfterDelete.first?.startDate?.startOfDay, date2.startOfDay)
    }
}
