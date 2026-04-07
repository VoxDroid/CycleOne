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

        XCTAssertTrue(app.staticTexts["Log Day"].waitForExistence(timeout: 5))

        UITestAppHarness.element(
            withIdentifier: "Log_DismissButton",
            in: app
        ).tap()
        XCTAssertTrue(app.navigationBars["CycleOne"].waitForExistence(timeout: 5))
    }
}
