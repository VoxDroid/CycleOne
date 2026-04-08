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
    private func tapLanguageOption(
        in app: XCUIApplication,
        settingsList: XCUIElement,
        currentPickerLabel: String,
        candidates: [String]
    ) -> Bool {
        for _ in 0 ..< 3 {
            for label in candidates {
                let exactPredicate = NSPredicate(format: "label == %@", label)
                let containsPredicate = NSPredicate(format: "label CONTAINS[c] %@", label)
                let queries: [XCUIElementQuery] = [
                    app.menuItems.matching(exactPredicate),
                    app.buttons.matching(exactPredicate),
                    app.staticTexts.matching(exactPredicate),
                    app.descendants(matching: .any).matching(exactPredicate),
                    app.descendants(matching: .any).matching(containsPredicate),
                ]

                for query in queries {
                    for option in query.allElementsBoundByIndex where option.exists {
                        if option.identifier == "Settings_LanguagePicker" {
                            continue
                        }

                        if option.label == currentPickerLabel,
                           option.elementType != .menuItem
                        {
                            continue
                        }

                        if option.isHittable {
                            option.tap()
                            return true
                        }
                    }
                }
            }

            settingsList.swipeDown()
        }

        return false
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
        let currentPickerLabel = languagePicker.label
        languagePicker.tap()

        let didSelectLanguage = tapLanguageOption(
            in: app,
            settingsList: settingsList,
            currentPickerLabel: currentPickerLabel,
            candidates: candidates
        )
        XCTAssertTrue(didSelectLanguage, "Unable to find any language option from candidates: \(candidates)")

        // Wait for the picker label to update when a new language has been selected.
        let pickerLabelChanged = expectation(
            for: NSPredicate(format: "label != %@", currentPickerLabel),
            evaluatedWith: languagePicker
        )
        _ = XCTWaiter.wait(for: [pickerLabelChanged], timeout: 8)

        UITestAppHarness.waitForMainTabs(in: app)
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
    private func assertLegendPeriodLabel(
        in app: XCUIApplication,
        expected: String,
        timeout: TimeInterval = 25
    ) {
        UITestAppHarness.openTab(at: 0, in: app)

        let legendRoot = UITestAppHarness.element(
            withIdentifier: "CalendarLegendView",
            in: app
        )
        XCTAssertTrue(legendRoot.waitForExistence(timeout: timeout))

        let periodLabel = UITestAppHarness.element(
            withIdentifier: "CalendarLegend_PeriodLabel",
            in: app
        )

        let deadline = Date().addingTimeInterval(timeout)
        var foundLocalizedLabel = false

        while Date() < deadline {
            if app.staticTexts[expected].exists {
                foundLocalizedLabel = true
                break
            }

            if periodLabel.exists, periodLabel.label.contains(expected) {
                foundLocalizedLabel = true
                break
            }

            if let periodValue = periodLabel.value as? String,
               periodValue.contains(expected)
            {
                foundLocalizedLabel = true
                break
            }

            if legendRoot.label.contains(expected) {
                foundLocalizedLabel = true
                break
            }

            _ = app.staticTexts[expected].waitForExistence(timeout: 0.3)
        }

        XCTAssertTrue(
            foundLocalizedLabel,
            "Expected legend period label '\(expected)' not found. Legend root label: '\(legendRoot.label)'"
        )
        XCTAssertFalse(app.staticTexts["calendar.legend.period"].exists)
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
            seedInsights: false,
            extraLaunchArguments: ["-ui-testing-language", "en"]
        )

        UITestAppHarness.waitForMainTabs(in: app)
        forcePortraitLayout()

        let settingsList = openSettingsList(in: app)
        selectLanguage(in: app, settingsList: settingsList, candidates: ["Japanese", "日本語"])

        assertLegendPeriodLabel(in: app, expected: "生理")

        let settingsListJapanese = openSettingsList(in: app)
        selectLanguage(in: app, settingsList: settingsListJapanese, candidates: ["English", "英語"])

        assertLegendPeriodLabel(in: app, expected: "Period")
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
