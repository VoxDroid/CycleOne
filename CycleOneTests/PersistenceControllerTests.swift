//
//  PersistenceControllerTests.swift
//  CycleOneTests
//

import CoreData
@testable import CycleOne
import XCTest

final class PersistenceControllerTests: XCTestCase {
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

    func testCreateAndFetchDayLog() throws {
        let date = Date().startOfDay
        let log = DayLog(context: context)
        log.id = UUID()
        log.date = date
        log.flowLevel = 3
        log.mood = 1

        try context.save()

        let request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", date as NSDate)
        let results = try context.fetch(request)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.flowLevel, 3)
    }

    func testSymptomRelationship() throws {
        let log = DayLog(context: context)
        log.id = UUID()
        log.date = Date().startOfDay

        let symptom = Symptom(context: context)
        symptom.id = "cramps"
        symptom.name = "Cramps"
        symptom.category = "Physical"
        symptom.dayLog = log

        log.addToSymptoms(symptom)

        try context.save()

        let request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        let results = try context.fetch(request)
        let fetchedLog = try XCTUnwrap(results.first)

        XCTAssertEqual(fetchedLog.symptoms?.count, 1)
        let fetchedSymptom = try XCTUnwrap(fetchedLog.symptoms?.anyObject() as? Symptom)
        XCTAssertEqual(fetchedSymptom.id, "cramps")
    }

    func testSaveWithoutChangesIsNoOp() {
        XCTAssertFalse(context.hasChanges)

        controller.save()

        XCTAssertFalse(context.hasChanges)
    }

    func testSavePersistsPendingChanges() throws {
        let log = DayLog(context: context)
        log.id = UUID()
        log.date = Date().startOfDay
        log.flowLevel = FlowLevel.light.rawValue

        XCTAssertTrue(context.hasChanges)

        controller.save()

        XCTAssertFalse(context.hasChanges)
        let request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        XCTAssertEqual(try context.count(for: request), 1)
    }

    func testModelContainsExpectedEntities() {
        let entityNames = Set(PersistenceController.model.entities.compactMap(\.name))

        XCTAssertTrue(entityNames.contains("DayLog"))
        XCTAssertTrue(entityNames.contains("Cycle"))
        XCTAssertTrue(entityNames.contains("Symptom"))
    }

    func testInMemoryStoreUsesDevNullAndExpectedContextFlags() {
        XCTAssertEqual(
            controller.container.persistentStoreDescriptions.first?.url?.path,
            "/dev/null"
        )
        XCTAssertTrue(context.automaticallyMergesChangesFromParent)
    }
}
