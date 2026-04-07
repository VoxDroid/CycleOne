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
    func testCalendarLayout() {
        let app = UITestAppHarness.launch(
            skipOnboarding: true,
            clearData: true,
            seedInsights: false
        )

        UITestAppHarness.waitForMainTabs(in: app)

        // Verify navigation title
        XCTAssertTrue(app.navigationBars["CycleOne"].waitForExistence(timeout: 5))

        let logButton = UITestAppHarness.element(
            withIdentifier: "Calendar_LogActionButton",
            in: app
        )
        XCTAssertTrue(logButton.exists)
    }

    @MainActor
    func testNavigationToLogView() {
        let app = UITestAppHarness.launch(
            skipOnboarding: true,
            clearData: true,
            seedInsights: false
        )

        UITestAppHarness.waitForMainTabs(in: app)

        let logButton = UITestAppHarness.element(
            withIdentifier: "Calendar_LogActionButton",
            in: app
        )
        XCTAssertTrue(logButton.waitForExistence(timeout: 5))
        logButton.tap()

        // Verify we are on the Log Day screen
        XCTAssertTrue(app.staticTexts["Log Day"].waitForExistence(timeout: 5))

        let dismissButton = UITestAppHarness.element(
            withIdentifier: "Log_DismissButton",
            in: app
        )
        XCTAssertTrue(dismissButton.waitForExistence(timeout: 5))
        dismissButton.tap()

        XCTAssertTrue(app.navigationBars["CycleOne"].waitForExistence(timeout: 5))
    }
}
