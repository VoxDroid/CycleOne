@testable import CycleOne
import Foundation
import XCTest

final class DateExtensionsTests: XCTestCase {
    func testStartOfDayRemovesTimeComponents() throws {
        let calendar = Calendar(identifier: .gregorian)
        let date = try XCTUnwrap(calendar.date(from: DateComponents(
            timeZone: TimeZone(secondsFromGMT: 0),
            year: 2026,
            month: 4,
            day: 1,
            hour: 16,
            minute: 45,
            second: 33
        )))

        let start = date.startOfDay
        let components = calendar.dateComponents([.hour, .minute, .second], from: start)

        XCTAssertEqual(components.hour, 0)
        XCTAssertEqual(components.minute, 0)
        XCTAssertEqual(components.second, 0)
    }

    func testIsSameDayReturnsExpectedResults() throws {
        let calendar = Calendar(identifier: .gregorian)
        let base = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 4, day: 1, hour: 8)))
        let sameDay = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 4, day: 1, hour: 22)))
        let nextDay = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 4, day: 2, hour: 1)))

        XCTAssertTrue(base.isSameDay(as: sameDay))
        XCTAssertFalse(base.isSameDay(as: nextDay))
    }

    func testFormattedAbbreviatedIsNotEmpty() {
        XCTAssertFalse(Date().formattedAbbreviated.isEmpty)
    }

    func testDaysFromHandlesPositiveAndNegativeDifferences() throws {
        let calendar = Calendar(identifier: .gregorian)
        let base = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 4, day: 1)))
        let plusThree = base.adding(days: 3)

        XCTAssertEqual(plusThree.days(from: base), 3)
        XCTAssertEqual(base.days(from: plusThree), -3)
    }

    func testAddingDaysSupportsNegativeOffsets() throws {
        let calendar = Calendar(identifier: .gregorian)
        let base = try XCTUnwrap(calendar.date(from: DateComponents(year: 2026, month: 4, day: 10)))

        XCTAssertEqual(base.adding(days: -2).days(from: base), -2)
        XCTAssertEqual(base.adding(days: 5).days(from: base), 5)
    }
}
