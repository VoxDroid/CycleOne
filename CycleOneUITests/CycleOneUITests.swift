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

        XCTAssertTrue(calendarTab.exists)
        XCTAssertTrue(insightsTab.exists)
        XCTAssertTrue(settingsTab.exists)

        insightsTab.tap()
        XCTAssertTrue(app.navigationBars["Insights"].exists)

        settingsTab.tap()
        XCTAssertTrue(app.navigationBars["Settings"].exists)

        calendarTab.tap()
    }

    @MainActor
    func testLoggingFlow() {
        let app = XCUIApplication()
        app.launch()

        let logButton = app.buttons["LogDayButton"]
        XCTAssertTrue(logButton.exists)
        logButton.tap()

        XCTAssertTrue(app.navigationBars.firstMatch.identifier != "")

        // Select Medium Flow
        let mediumButton = app.buttons["Medium"]
        if mediumButton.exists {
            mediumButton.tap()
        }

        let saveButton = app.buttons["SaveLogButton"]
        XCTAssertTrue(saveButton.exists)
        saveButton.tap()

        // Wait for sheet to dismiss
        XCTAssertTrue(logButton.waitForExistence(timeout: 5))
    }
}
