//
//  PersistenceControllerTests.swift
//  CycleOneTests
//
//  Created by Antigravity on 3/23/26.
//

import CoreData
@testable import CycleOne
import XCTest

final class PersistenceControllerTests: XCTestCase {
    var persistence: TestPersistenceController!

    override func setUp() {
        super.setUp()
        persistence = TestPersistenceController()
    }

    override func tearDown() {
        persistence = nil
        super.tearDown()
    }

    func testCreateDayLog() throws {
        let context = persistence.container.viewContext
        let date = Date()

        let log = DayLog(context: context)
        log.id = UUID()
        log.date = Calendar.current.startOfDay(for: date)
        log.flowLevel = FlowLevel.medium.rawValue
        log.mood = Mood.happy.rawValue
        log.energyLevel = EnergyLevel.high.rawValue
        log.painLevel = 2

        try context.save()

        let fetchRequest: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        let results = try context.fetch(fetchRequest)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.flowLevel, FlowLevel.medium.rawValue)
        XCTAssertEqual(results.first?.mood, Mood.happy.rawValue)
        XCTAssertEqual(results.first?.energyLevel, EnergyLevel.high.rawValue)
        XCTAssertEqual(results.first?.painLevel, 2)
    }

    func testCreateCycleWithLogs() throws {
        let context = persistence.container.viewContext

        let cycle = Cycle(context: context)
        cycle.id = UUID()
        cycle.startDate = Date()

        let log = DayLog(context: context)
        log.id = UUID()
        log.date = Date()
        log.cycle = cycle

        try context.save()

        let fetchRequest: NSFetchRequest<Cycle> = Cycle.fetchRequest()
        let results = try context.fetch(fetchRequest)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.dayLogs?.count, 1)
    }

    func testCascadeDeleteSymptom() throws {
        let context = persistence.container.viewContext

        let log = DayLog(context: context)
        log.id = UUID()
        log.date = Date()

        let symptom = Symptom(context: context)
        symptom.id = "cramps"
        symptom.name = "Cramps"
        symptom.category = SymptomCategory.physical.rawValue
        symptom.dayLog = log

        try context.save()

        // Delete log
        context.delete(log)
        try context.save()

        let symptomRequest: NSFetchRequest<Symptom> = Symptom.fetchRequest()
        let symptoms = try context.fetch(symptomRequest)

        XCTAssertEqual(symptoms.count, 0, "Symptom should be cascade deleted when DayLog is deleted")
    }
}
