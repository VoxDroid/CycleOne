//
//  CycleEngineTests.swift
//  CycleOneTests
//

@testable import CycleOne
import XCTest

final class CycleEngineTests: XCTestCase {
    var engine: CycleEngine!

    override func setUp() {
        super.setUp()
        engine = CycleEngine()
    }

    override func tearDown() {
        engine = nil
        super.tearDown()
    }

    func testPredictNextPeriod_WithNoCycles() {
        let result = engine.predictNextPeriodStart(from: [])
        XCTAssertNil(result)
    }

    func testPredictNextPeriod_WithOneCycle() {
        let context = TestPersistenceController.empty().container.viewContext
        let startDate = Date()
        let cycle = Cycle(context: context)
        cycle.startDate = startDate
        cycle.cycleLength = 30

        let result = engine.predictNextPeriodStart(from: [cycle])

        XCTAssertNotNil(result)
        let expectedDate = Calendar.current.date(byAdding: .day, value: 30, to: startDate)
        XCTAssertEqual(result, expectedDate)
    }

    func testPredictNextPeriod_WithAverage() throws {
        let context = TestPersistenceController.empty().container.viewContext
        let calendar = Calendar.current
        let start1 = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 1, day: 1)))
        let start2 = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 2, day: 1)))

        let cycle1 = Cycle(context: context)
        cycle1.startDate = start1
        cycle1.cycleLength = 31

        let cycle2 = Cycle(context: context)
        cycle2.startDate = start2
        cycle2.cycleLength = 28

        let result = engine.predictNextPeriodStart(from: [cycle1, cycle2])

        // Average: (31 + 28) / 2 = 29
        let expectedDate = calendar.date(byAdding: .day, value: 29, to: start2)
        XCTAssertEqual(result, expectedDate)
    }

    func testPredictOvulation() throws {
        let context = TestPersistenceController.empty().container.viewContext
        let startDate = Date()
        let cycle = Cycle(context: context)
        cycle.startDate = startDate
        cycle.cycleLength = 30

        let result = engine.predictOvulation(from: [cycle])
        XCTAssertNotNil(result)

        let nextPeriod = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: 30, to: startDate))
        let expectedDate = Calendar.current.date(byAdding: .day, value: -14, to: nextPeriod)
        XCTAssertEqual(result, expectedDate)
    }

    func testIsCycleIrregular() {
        let context = TestPersistenceController.empty().container.viewContext
        let cycle1 = Cycle(context: context)
        cycle1.cycleLength = 28

        let cycle2 = Cycle(context: context)
        cycle2.cycleLength = 40 // Diff of 12

        XCTAssertTrue(engine.isCycleIrregular(cycles: [cycle1, cycle2]))
    }
}
