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

        // Find the NavigationLink to LogView
        let logButton = app.buttons
            .matching(NSPredicate(format: "label CONTAINS 'Log Day' OR label CONTAINS 'Edit Log'")).firstMatch
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

        // Tap the Log Day button
        let logButton = app.buttons
            .matching(NSPredicate(format: "label CONTAINS 'Log Day' OR label CONTAINS 'Edit Log'")).firstMatch
        XCTAssertTrue(logButton.waitForExistence(timeout: 5))
        logButton.tap()

        // Verify we are on the Log Day screen
        XCTAssertTrue(app.staticTexts["Log Day"].waitForExistence(timeout: 5))

        let dismissButton = app.buttons["Dismiss"]
        XCTAssertTrue(dismissButton.waitForExistence(timeout: 5))
        dismissButton.tap()

        XCTAssertTrue(app.navigationBars["CycleOne"].waitForExistence(timeout: 5))
    }
}
