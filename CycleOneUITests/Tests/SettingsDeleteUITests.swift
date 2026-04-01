import XCTest

final class SettingsDeleteUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testDeleteAllData_alert_confirms() {
        let app = UITestAppHarness.launch(
            skipOnboarding: true,
            clearData: true,
            seedInsights: false
        )

        UITestAppHarness.waitForMainTabs(in: app)

        // Ensure consistent orientation
        XCUIDevice.shared.orientation = .portrait

        // Open Settings tab (index 2)
        let settingsTab = app.tabBars.buttons.element(boundBy: 2)
        XCTAssertTrue(settingsTab.waitForExistence(timeout: 10))
        settingsTab.tap()

        let settingsList = app.collectionViews["SettingsList"]
        XCTAssertTrue(settingsList.waitForExistence(timeout: 10))

        // Try tapping the Delete All Data button
        let deleteButton = app.buttons["Delete All Data"]
        if deleteButton.waitForExistence(timeout: 5) {
            deleteButton.tap()
        } else if let cell = app.staticTexts["Delete All Data"].firstMatch as XCUIElement? {
            XCTAssertTrue(cell.waitForExistence(timeout: 5))
            cell.tap()
        } else {
            XCTFail("Couldn't find Delete All Data control")
        }

        // Confirm alert and tap Delete
        let deleteAlertButton = app.alerts.buttons["Delete"]
        XCTAssertTrue(deleteAlertButton.waitForExistence(timeout: 5))
        deleteAlertButton.tap()
    }
}
