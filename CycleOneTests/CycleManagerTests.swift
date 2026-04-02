//
//  CycleManagerTests.swift
//  CycleOneTests
//

import CoreData
@testable import CycleOne
import XCTest

final class CycleManagerTests: XCTestCase {
    private final class ThrowingSaveManagedObjectContext: NSManagedObjectContext, @unchecked Sendable {
        private(set) var saveCallCount = 0

        override func save() throws {
            saveCallCount += 1
            throw NSError(domain: "CycleManagerTests", code: 1)
        }
    }

    private final class SelectiveThrowManagedObjectContext: NSManagedObjectContext, @unchecked Sendable {
        var failingFetchEntities = Set<String>()

        override func execute(_ request: NSPersistentStoreRequest) throws -> NSPersistentStoreResult {
            if let fetchRequest = request as? NSFetchRequest<NSFetchRequestResult>,
               let entityName = fetchRequest.entityName,
               failingFetchEntities.contains(entityName)
            {
                throw NSError(
                    domain: "CycleManagerTests",
                    code: 2,
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
        XCTAssertEqual(initialLogs.count, 2)

        // 2. Rebuild
        CycleManager.shared.rebuildAllCycles(in: context)

        // 3. Verify cycles
        let request: NSFetchRequest<Cycle> = Cycle.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Cycle.startDate, ascending: true)]
        let cycles = try context.fetch(request)

        XCTAssertEqual(cycles.count, 2)
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

    func testRebuildAllCycles_handlesSaveFailuresWithoutCrashing() throws {
        let coordinator = try makeInMemoryCoordinator()

        let seedContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        seedContext.persistentStoreCoordinator = coordinator

        let existingCycle = Cycle(context: seedContext)
        existingCycle.id = UUID()
        existingCycle.startDate = Date().adding(days: -80).startOfDay
        existingCycle.createdAt = Date()

        let baseDate = Date().adding(days: -30).startOfDay

        let firstLog = DayLog(context: seedContext)
        firstLog.id = UUID()
        firstLog.date = baseDate
        firstLog.flowLevel = FlowLevel.light.rawValue

        let secondLog = DayLog(context: seedContext)
        secondLog.id = UUID()
        secondLog.date = baseDate.adding(days: 1)
        secondLog.flowLevel = FlowLevel.none.rawValue

        let thirdLog = DayLog(context: seedContext)
        thirdLog.id = UUID()
        thirdLog.date = baseDate.adding(days: 30)
        thirdLog.flowLevel = FlowLevel.heavy.rawValue

        try seedContext.save()

        let throwingContext = ThrowingSaveManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        throwingContext.persistentStoreCoordinator = coordinator

        CycleManager.shared.rebuildAllCycles(in: throwingContext)

        XCTAssertGreaterThanOrEqual(throwingContext.saveCallCount, 2)
    }

    func testUpdateCycleMetrics_periodLengthStopsAtNonFlowDay() throws {
        let startDate = Date().adding(days: -6).startOfDay

        let cycle = Cycle(context: context)
        cycle.id = UUID()
        cycle.startDate = startDate
        cycle.createdAt = Date()

        let flowLog = DayLog(context: context)
        flowLog.id = UUID()
        flowLog.date = startDate
        flowLog.flowLevel = FlowLevel.medium.rawValue

        let noFlowLog = DayLog(context: context)
        noFlowLog.id = UUID()
        noFlowLog.date = startDate.adding(days: 1)
        noFlowLog.flowLevel = FlowLevel.none.rawValue

        try context.save()

        CycleManager.shared.updateCycleMetrics(in: context)

        let request: NSFetchRequest<Cycle> = Cycle.fetchRequest()
        let cycles = try context.fetch(request)
        XCTAssertEqual(cycles.first?.periodLength, 1)
    }

    func testFullSync_runsFromBackgroundQueue() {
        let expectation = expectation(description: "fullSync completes")

        DispatchQueue.global(qos: .userInitiated).async {
            CycleManager.shared.fullSync(in: self.context)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    func testRebuildAllCycles_handlesCycleFetchFailure() throws {
        let coordinator = try makeInMemoryCoordinator()
        let throwingContext = SelectiveThrowManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        throwingContext.persistentStoreCoordinator = coordinator
        throwingContext.failingFetchEntities = ["Cycle"]

        CycleManager.shared.rebuildAllCycles(in: throwingContext)

        XCTAssertTrue(true)
    }

    func testRebuildAllCycles_handlesLogFetchFailure() throws {
        let coordinator = try makeInMemoryCoordinator()
        let throwingContext = SelectiveThrowManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        throwingContext.persistentStoreCoordinator = coordinator

        let existingCycle = Cycle(context: throwingContext)
        existingCycle.id = UUID()
        existingCycle.startDate = Date().startOfDay
        existingCycle.createdAt = Date()
        try throwingContext.save()

        throwingContext.failingFetchEntities = ["DayLog"]

        CycleManager.shared.rebuildAllCycles(in: throwingContext)

        let request: NSFetchRequest<Cycle> = Cycle.fetchRequest()
        let cycles = try throwingContext.fetch(request)
        XCTAssertTrue(cycles.isEmpty)
    }

    func testUpdateCycleMetrics_handlesFetchFailure() throws {
        let coordinator = try makeInMemoryCoordinator()
        let throwingContext = SelectiveThrowManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        throwingContext.persistentStoreCoordinator = coordinator
        throwingContext.failingFetchEntities = ["Cycle"]

        CycleManager.shared.updateCycleMetrics(in: throwingContext)

        XCTAssertTrue(true)
    }

    func testDebugExtractHelpers_coverValueVariants() {
        let manager = CycleManager.shared
        let today = Date().startOfDay

        XCTAssertEqual(manager.testExtractDate(from: today)?.startOfDay, today)
        XCTAssertEqual(manager.testExtractDate(from: today as NSDate)?.startOfDay, today)
        XCTAssertNil(manager.testExtractDate(from: "invalid"))

        XCTAssertEqual(manager.testExtractInt16(from: NSNumber(value: 3)), 3)
        XCTAssertEqual(manager.testExtractInt16(from: Int16(4)), 4)
        XCTAssertEqual(manager.testExtractInt16(from: 5), 5)
        XCTAssertEqual(manager.testExtractInt16(from: "invalid"), 0)

        XCTAssertEqual(manager.testCycleLength(from: today, nextStartValue: nil), 0)
        XCTAssertEqual(
            manager.testCycleLength(
                from: today,
                nextStartValue: today.adding(days: 2)
            ),
            2
        )
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
