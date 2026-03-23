//
//  SettingsUITests.swift
//  CycleOneUITests
//

import XCTest

final class SettingsUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testSettingsNavigation() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["SettingsTab"].tap()
        XCTAssertTrue(app.navigationBars["Settings"].exists)

        app.staticTexts["Notifications"].tap()
        XCTAssertTrue(app.navigationBars["Notifications"].exists)
    }
}
