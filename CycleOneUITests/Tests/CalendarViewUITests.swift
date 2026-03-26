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
        let app = XCUIApplication()
        app.launch()
        dismissOnboarding(app: app)

        // Verify navigation title
        XCTAssertTrue(app.navigationBars["CycleOne"].waitForExistence(timeout: 5))

        // Find the NavigationLink to LogView
        let logButton = app.buttons
            .matching(NSPredicate(format: "label CONTAINS 'Log Day' OR label CONTAINS 'Edit Log'")).firstMatch
        XCTAssertTrue(logButton.exists)
    }

    @MainActor
    func testNavigationToLogView() {
        let app = XCUIApplication()
        app.launch()
        dismissOnboarding(app: app)

        // Tap the Log Day button
        let logButton = app.buttons
            .matching(NSPredicate(format: "label CONTAINS 'Log Day' OR label CONTAINS 'Edit Log'")).firstMatch
        XCTAssertTrue(logButton.waitForExistence(timeout: 5))
        logButton.tap()

        // Verify we are on the Log Day screen
        XCTAssertTrue(app.staticTexts["Log Day"].waitForExistence(timeout: 5))

        // Use standard back button or "Dismiss"
        if app.buttons["Dismiss"].exists {
            app.buttons["Dismiss"].tap()
        } else {
            app.navigationBars.buttons.element(boundBy: 0).tap()
        }

        XCTAssertTrue(app.navigationBars["CycleOne"].waitForExistence(timeout: 5))
    }

    private func dismissOnboarding(app: XCUIApplication) {
        // Wait for splash screen to auto-dismiss
        sleep(3)

        // Handle multi-page onboarding
        let skipButton = app.buttons["Skip"]
        if skipButton.waitForExistence(timeout: 2) {
            skipButton.tap()
            return
        }

        let getStartedButton = app.buttons["Get Started"]
        if getStartedButton.waitForExistence(timeout: 2) {
            getStartedButton.tap()
            return
        }
    }
}
