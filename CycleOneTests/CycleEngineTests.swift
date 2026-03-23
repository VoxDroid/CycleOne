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
        let startDate = Date()
        let cycles = [CycleSnapshot(startDate: startDate, cycleLength: 30, periodLength: 5)]

        let result = engine.predictNextPeriodStart(from: cycles)

        XCTAssertNotNil(result)
        let expectedDate = Calendar.current.date(byAdding: .day, value: 30, to: startDate)
        XCTAssertEqual(result, expectedDate)
    }

    func testPredictNextPeriod_WithAverage() throws {
        let calendar = Calendar.current
        let start1 = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 1, day: 1)))
        let start2 = try XCTUnwrap(calendar.date(from: DateComponents(year: 2024, month: 2, day: 1))) // 31 days

        let cycles = [
            CycleSnapshot(startDate: start1, cycleLength: 31, periodLength: 5),
            CycleSnapshot(startDate: start2, cycleLength: 28, periodLength: 5),
        ]

        let result = engine.predictNextPeriodStart(from: cycles)

        // Average: (31 + 28) / 2 = 29.5 (int: 29)
        let expectedDate = calendar.date(byAdding: .day, value: 29, to: start2)
        XCTAssertEqual(result, expectedDate)
    }

    func testEstimatedOvulationDate() {
        let nextPeriod = Date()
        let result = engine.estimatedOvulationDate(nextPeriodStart: nextPeriod)

        let expectedDate = Calendar.current.date(byAdding: .day, value: -14, to: nextPeriod)
        XCTAssertEqual(result, expectedDate)
    }

    func testFertileWindow() {
        let ovulation = Date()
        let result = engine.fertileWindow(ovulationDate: ovulation)

        XCTAssertEqual(result.count, 6)
        XCTAssertEqual(result.last, ovulation)
    }

    func testIrregularCycles() {
        let startDate = Date()
        let cycles = [
            CycleSnapshot(startDate: startDate, cycleLength: 28, periodLength: 5),
            CycleSnapshot(startDate: startDate, cycleLength: 38, periodLength: 5), // Diff of 10
        ]

        XCTAssertTrue(engine.cyclesAreIrregular(cycles))
    }

    func testPredictNextPeriod_UsesOnlyLast3Cycles() {
        let calendar = Calendar.current
        let start = Date()

        let cycles = [
            CycleSnapshot(startDate: start, cycleLength: 50, periodLength: 5), // Ignored (outlier + not in last 3)
            CycleSnapshot(startDate: start, cycleLength: 28, periodLength: 5),
            CycleSnapshot(startDate: start, cycleLength: 30, periodLength: 5),
            CycleSnapshot(startDate: start, cycleLength: 32, periodLength: 5),
        ]

        let result = engine.predictNextPeriodStart(from: cycles)

        // Average of (28 + 30 + 32) / 3 = 30
        let expectedDate = calendar.date(byAdding: .day, value: 30, to: start)
        XCTAssertEqual(result, expectedDate)
    }

    func testPredictNextPeriod_FiltersOutliers() {
        let calendar = Calendar.current
        let start = Date()

        let cycles = [
            CycleSnapshot(startDate: start, cycleLength: 15, periodLength: 5), // Outlier (< 21)
            CycleSnapshot(startDate: start, cycleLength: 50, periodLength: 5), // Outlier (> 45)
            CycleSnapshot(startDate: start, cycleLength: 30, periodLength: 5), // Only valid one
        ]

        let result = engine.predictNextPeriodStart(from: cycles)

        // Only 30 should be used.
        let expectedDate = calendar.date(byAdding: .day, value: 30, to: start)
        XCTAssertEqual(result, expectedDate)
    }
}
