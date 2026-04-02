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
        let app = UITestAppHarness.launch(
            skipOnboarding: true,
            clearData: true,
            seedInsights: false
        )

        UITestAppHarness.waitForMainTabs(in: app)

        // Force portrait orientation for consistent testing layout
        XCUIDevice.shared.orientation = .portrait

        // Tap Settings tab (Settings is the third tab, index 2)
        let settingsTab = app.tabBars.buttons.element(boundBy: 2)
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 10))
        settingsTab.tap()

        // Wait for list to load
        let settingsList = app.collectionViews["SettingsList"]
        XCTAssertTrue(settingsList.waitForExistence(timeout: 10))

        // Verify Appearance section and Accent Color picker exist
        let accentColor = app.staticTexts["AccentColorTitle"]

        // Scroll list specifically until visible
        var retryCount = 0
        while !accentColor.isHittable, retryCount < 5 {
            settingsList.swipeUp()
            retryCount += 1
        }

        if !accentColor.waitForExistence(timeout: 15) {
            XCTFail("Expected accent color picker in Settings. Title not found.")
        }
    }

    @MainActor
    func testAccentSelectionTap_updatesAccentChoice() {
        let app = UITestAppHarness.launch(
            skipOnboarding: true,
            clearData: true,
            seedInsights: false
        )

        UITestAppHarness.waitForMainTabs(in: app)

        let settingsTab = app.tabBars.buttons.element(boundBy: 2)
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 10))
        settingsTab.tap()

        let settingsList = app.collectionViews["SettingsList"]
        XCTAssertTrue(settingsList.waitForExistence(timeout: 10))

        let lavenderAccent = app.buttons["Settings_Accent_Lavender"]
        var attempts = 0
        while !lavenderAccent.isHittable, attempts < 5 {
            settingsList.swipeUp()
            attempts += 1
        }

        XCTAssertTrue(lavenderAccent.waitForExistence(timeout: 8))
        lavenderAccent.tap()

        XCTAssertTrue(lavenderAccent.exists)
    }
}
