//
//  CycleOneUITests.swift
//  CycleOneUITests
//
//  Created by Drei on 3/23/26.
//

import XCTest

final class CycleOneUITests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests
        // before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testNavigation() {
        let app = XCUIApplication()
        app.launch()

        let calendarTab = app.tabBars.buttons["CalendarTab"]
        let insightsTab = app.tabBars.buttons["InsightsTab"]
        let settingsTab = app.tabBars.buttons["SettingsTab"]

        XCTAssertTrue(calendarTab.waitForExistence(timeout: 5))
        XCTAssertTrue(insightsTab.waitForExistence(timeout: 5))
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))

        insightsTab.tap()
        XCTAssertTrue(app.staticTexts["Insights"].waitForExistence(timeout: 5))

        settingsTab.tap()
        XCTAssertTrue(app.staticTexts["Settings"].waitForExistence(timeout: 5))

        calendarTab.tap()
        // Check for navigation title or month header to confirm we're back on Calendar
        XCTAssertTrue(app.navigationBars["CycleOne"].exists)
    }

    @MainActor
    func testLoggingFlow() {
        let app = XCUIApplication()
        app.launch()

        let logButton = app.buttons["LogDayButton"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 5))
        logButton.tap()

        // Just check if we've opened a sheet
        XCTAssertTrue(app.buttons["SaveLogButton"].waitForExistence(timeout: 5))

        app.buttons["SaveLogButton"].tap()

        XCTAssertTrue(logButton.waitForExistence(timeout: 5))
    }

    @MainActor
    func testCalendarNavigation() {
        let app = XCUIApplication()
        app.launch()

        // Check for specific month text based on current date
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMMM yyyy"
        let currentMonth = monthFormatter.string(from: Date())

        // Graphical DatePicker identifies its month header in staticTexts
        XCTAssertTrue(app.staticTexts[currentMonth].exists)
    }
}
