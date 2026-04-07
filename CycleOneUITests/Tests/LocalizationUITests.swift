import XCTest

final class LocalizationUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    private func forcePortraitLayout() {
        XCUIDevice.shared.orientation = .portrait
    }

    @MainActor
    private func selectLanguage(
        in app: XCUIApplication,
        settingsList: XCUIElement,
        candidates: [String]
    ) {
        let languagePicker = UITestAppHarness.element(
            withIdentifier: "Settings_LanguagePicker",
            in: app
        )

        UITestAppHarness.scrollToElement(languagePicker, in: settingsList)
        XCTAssertTrue(languagePicker.waitForExistence(timeout: 8))
        if !languagePicker.isHittable {
            settingsList.swipeDown()
            UITestAppHarness.scrollToElement(languagePicker, in: settingsList)
        }
        XCTAssertTrue(languagePicker.isHittable)
        languagePicker.tap()

        for label in candidates {
            let optionCandidates: [XCUIElement] = [
                app.buttons[label],
                app.staticTexts[label],
                app.menuItems[label],
                app.descendants(matching: .any)
                    .matching(NSPredicate(format: "label == %@", label))
                    .firstMatch,
                app.descendants(matching: .any)
                    .matching(NSPredicate(format: "label CONTAINS[c] %@", label))
                    .firstMatch,
            ]

            for option in optionCandidates where option.waitForExistence(timeout: 2) {
                option.tap()
                return
            }
        }

        XCTFail("Unable to find any language option from candidates: \(candidates)")
    }

    @MainActor
    private func openSettingsList(in app: XCUIApplication) -> XCUIElement {
        UITestAppHarness.openTab(at: 2, in: app)
        let settingsList = UITestAppHarness.element(
            withIdentifier: "SettingsList",
            in: app
        )
        XCTAssertTrue(settingsList.waitForExistence(timeout: 10))
        return settingsList
    }

    @MainActor
    func testSettingsLanguageSwitchToJapanese_updatesVisibleStrings() {
        let app = UITestAppHarness.launch(
            skipOnboarding: true,
            clearData: true,
            seedInsights: false
        )

        UITestAppHarness.waitForMainTabs(in: app)
        forcePortraitLayout()
        let settingsList = openSettingsList(in: app)
        selectLanguage(in: app, settingsList: settingsList, candidates: ["Japanese", "日本語"])

        UITestAppHarness.openTab(at: 0, in: app)
        UITestAppHarness.openTab(at: 2, in: app)

        let japaneseSettingsTab = app.tabBars.buttons["設定"]
        if japaneseSettingsTab.waitForExistence(timeout: 8) {
            XCTAssertTrue(true)
            return
        }

        XCTAssertTrue(app.staticTexts["言語"].waitForExistence(timeout: 8))
    }

    @MainActor
    func testCalendarLegend_remainsLocalizedAfterLanguageRoundTrip() {
        let app = UITestAppHarness.launch(
            skipOnboarding: true,
            clearData: true,
            seedInsights: false
        )

        UITestAppHarness.waitForMainTabs(in: app)
        forcePortraitLayout()

        let settingsList = openSettingsList(in: app)
        selectLanguage(in: app, settingsList: settingsList, candidates: ["Japanese", "日本語"])

        UITestAppHarness.openTab(at: 0, in: app)
        XCTAssertTrue(app.staticTexts["生理"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["calendar.legend.period"].exists)

        let settingsListJapanese = openSettingsList(in: app)
        selectLanguage(in: app, settingsList: settingsListJapanese, candidates: ["English", "英語"])

        UITestAppHarness.openTab(at: 0, in: app)
        XCTAssertTrue(app.staticTexts["Period"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["calendar.legend.period"].exists)
    }

    @MainActor
    func testLanguageSwitchFromFilipinoToJapanese_updatesSettingsAndCalendar() {
        let app = UITestAppHarness.launch(
            skipOnboarding: true,
            clearData: true,
            seedInsights: false,
            extraLaunchArguments: ["-ui-testing-language", "fil"]
        )

        UITestAppHarness.waitForMainTabs(in: app)
        forcePortraitLayout()

        let settingsList = openSettingsList(in: app)
        XCTAssertTrue(app.navigationBars["Mga Setting"].waitForExistence(timeout: 8))

        selectLanguage(
            in: app,
            settingsList: settingsList,
            candidates: ["Hapones", "Japanese", "日本語"]
        )

        XCTAssertTrue(app.navigationBars["設定"].waitForExistence(timeout: 8))
        XCTAssertFalse(app.navigationBars["Mga Setting"].exists)

        UITestAppHarness.openTab(at: 0, in: app)
        XCTAssertTrue(app.staticTexts["生理"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["Regla"].exists)
        XCTAssertFalse(app.staticTexts["calendar.legend.period"].exists)
    }
}
