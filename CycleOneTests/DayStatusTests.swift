@testable import CycleOne
import XCTest

final class DayStatusTests: XCTestCase {
    func testFillColorIsNilWhenNoFlagsAreSet() {
        let status = DayStatus()
        XCTAssertNil(status.fillColor)
    }

    func testFillColorForFlow() {
        var status = DayStatus()
        status.flow = .medium
        XCTAssertNotNil(status.fillColor)
    }

    func testFillColorForPredictedDay() {
        var status = DayStatus()
        status.isPredicted = true
        XCTAssertNotNil(status.fillColor)
    }

    func testFillColorForOvulationDay() {
        var status = DayStatus()
        status.isOvulation = true
        XCTAssertNotNil(status.fillColor)
    }

    func testFillColorForFertileDayIsNil() {
        var status = DayStatus()
        status.isFertile = true
        XCTAssertNil(status.fillColor)
    }

    func testFillColorPriorityPrefersFlowOverOtherFlags() {
        var status = DayStatus()
        status.flow = .heavy
        status.isPredicted = true
        status.isOvulation = true
        status.isFertile = true

        XCTAssertNotNil(status.fillColor)
    }
}
