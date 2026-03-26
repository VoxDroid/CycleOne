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
        dismissOnboarding(app: app)

        // Tap Settings tab (Settings is the third tab, index 2)
        let settingsTab = app.tabBars.buttons.element(boundBy: 2)
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 5))
        settingsTab.tap()

        // Verify Appearance section and Accent Color picker exist
        let accentColor = app.staticTexts["AccentColorTitle"]
        if !accentColor.waitForExistence(timeout: 5) {
            print("UI Hierarchy: \(app.debugDescription)")
            XCTFail("Expected accent color picker in Settings. Title not found.")
        }
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
