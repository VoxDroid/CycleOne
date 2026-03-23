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

        let logButton = app.buttons["LogDayButton"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 5))
        logButton.tap()

        XCTAssertTrue(app.staticTexts["Log Day"].waitForExistence(timeout: 5))

        app.buttons["Done"].tap()
        XCTAssertTrue(logButton.waitForExistence(timeout: 5))
    }
}
