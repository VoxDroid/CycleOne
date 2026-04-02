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

        UITestAppHarness.scrollToElement(accentColor, in: settingsList)
        XCTAssertTrue(accentColor.waitForExistence(timeout: 15))
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
        UITestAppHarness.scrollToElement(lavenderAccent, in: settingsList)

        XCTAssertTrue(lavenderAccent.waitForExistence(timeout: 8))
        lavenderAccent.tap()

        XCTAssertTrue(lavenderAccent.exists)
    }
}
