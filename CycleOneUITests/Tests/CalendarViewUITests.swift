//
//  CalendarViewUITests.swift
//  CycleOneUITests
//

import XCTest

final class CalendarViewUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testCalendarNavigation() {
        let app = XCUIApplication()
        app.launch()

        // Check for specific month text
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM yyyy"
        let currentMonth = monthFormatter.string(from: Date())

        XCTAssertTrue(app.staticTexts[currentMonth].exists)

        // Tap next month
        app.buttons["chevron.right"].tap()
        // ... verify next month
    }
}
