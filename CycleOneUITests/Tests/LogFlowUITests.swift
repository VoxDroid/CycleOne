//
//  LogFlowUITests.swift
//  CycleOneUITests
//

import XCTest

final class LogFlowUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testBasicLogging() {
        let app = XCUIApplication()
        app.launch()
        dismissOnboarding(app: app)

        // Find the Log/Edit button using a predicate
        let logButton = app.buttons
            .matching(NSPredicate(format: "label CONTAINS 'Log Day' OR label CONTAINS 'Edit Log'")).firstMatch
        XCTAssertTrue(logButton.waitForExistence(timeout: 5))
        logButton.tap()

        XCTAssertTrue(app.staticTexts["Log Day"].waitForExistence(timeout: 5))

        // We use "Dismiss" now, and it auto-saves
        app.buttons["Dismiss"].tap()
        XCTAssertTrue(app.navigationBars["CycleOne"].waitForExistence(timeout: 5))
    }

    private func dismissOnboarding(app: XCUIApplication) {
        let gotItButton = app.buttons["Got it!"]
        if gotItButton.waitForExistence(timeout: 2) {
            gotItButton.tap()
        }
    }
}
