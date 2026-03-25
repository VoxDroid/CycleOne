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
    func testThemePickerExists() {
        let app = XCUIApplication()
        app.launch()

        // Tap Settings tab (Settings is the third tab, index 2)
        let settingsTab = app.tabBars.buttons.element(boundBy: 2)
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        // Verify Theme picker exists
        XCTAssertTrue(app.staticTexts["Theme"].waitForExistence(timeout: 5))
    }
}
