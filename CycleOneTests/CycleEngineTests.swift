//
//  CycleEngineTests.swift
//  CycleOneTests
//

import CoreData
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
        let startDate = Date().startOfDay
        let cycle = Cycle(context: context)
        cycle.startDate = startDate
        cycle.cycleLength = 30

        let result = engine.predictNextPeriodStart(from: [cycle])

        XCTAssertNotNil(result)
        let expectedDate = Calendar.current.date(byAdding: .day, value: 30, to: startDate)
        XCTAssertEqual(result?.startOfDay, expectedDate?.startOfDay)
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

        // (31 + 28) / 2 = 29.5 -> rounds to 29 or 30? Int division is 29.
        let result = engine.predictNextPeriodStart(from: [cycle1, cycle2])

        let expectedDate = calendar.date(byAdding: .day, value: 29, to: start2)
        XCTAssertEqual(result?.startOfDay, expectedDate?.startOfDay)
    }

    func testPredictNextPeriod_filtersOutliers() throws {
        let context = TestPersistenceController.empty().container.viewContext
        let calendar = Calendar.current
        let start1 = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 1, day: 1)))
        let start2 = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 2, day: 1)))
        let start3 = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 3, day: 1)))

        let cycle1 = Cycle(context: context)
        cycle1.startDate = start1
        cycle1.cycleLength = 31

        let cycle2 = Cycle(context: context)
        cycle2.startDate = start2
        cycle2.cycleLength = 10 // Outlier (too short)

        let cycle3 = Cycle(context: context)
        cycle3.startDate = start3
        cycle3.cycleLength = 28

        let result = engine.predictNextPeriodStart(from: [cycle1, cycle2, cycle3])

        // Only cycle1 (31) and cycle3 (28) are used. Avg = 29.
        let expectedDate = calendar.date(byAdding: .day, value: 29, to: start3)
        XCTAssertEqual(result?.startOfDay, expectedDate?.startOfDay)
    }

    func testIsCycleIrregular() {
        let context = TestPersistenceController.empty().container.viewContext

        let cycle1 = Cycle(context: context)
        cycle1.cycleLength = 28

        let cycle2 = Cycle(context: context)
        cycle2.cycleLength = 40 // Diff of 12

        XCTAssertTrue(engine.isCycleIrregular(cycles: [cycle1, cycle2]))

        let cycle3 = Cycle(context: context)
        cycle3.cycleLength = 28
        let cycle4 = Cycle(context: context)
        cycle4.cycleLength = 30
        XCTAssertFalse(engine.isCycleIrregular(cycles: [cycle3, cycle4]))
    }
}
