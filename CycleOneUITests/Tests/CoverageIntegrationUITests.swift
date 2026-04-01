import XCTest

final class CoverageIntegrationUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testOnboardingFlowAdvancesAndDismisses() {
        let app = UITestAppHarness.launch(
            skipOnboarding: false,
            clearData: true,
            seedInsights: false
        )

        let onboardingRoot = UITestAppHarness.element(
            withIdentifier: "OnboardingTipView",
            in: app
        )
        XCTAssertTrue(onboardingRoot.waitForExistence(timeout: 12))
        XCTAssertTrue(app.staticTexts["Welcome to CycleOne"].waitForExistence(timeout: 5))

        for _ in 0 ..< 3 {
            let nextButton = app.buttons["Next"]
            XCTAssertTrue(nextButton.waitForExistence(timeout: 5))
            nextButton.tap()
        }

        let getStartedButton = app.buttons["Get Started"]
        XCTAssertTrue(getStartedButton.waitForExistence(timeout: 5))
        getStartedButton.tap()

        UITestAppHarness.waitForMainTabs(in: app)
    }

    @MainActor
    func testSettingsHelpPrivacyAndAboutNavigation() {
        let app = UITestAppHarness.launch(
            skipOnboarding: true,
            clearData: true,
            seedInsights: false
        )

        UITestAppHarness.waitForMainTabs(in: app)
        UITestAppHarness.openTab(at: 2, in: app)

        let settingsList = UITestAppHarness.element(
            withIdentifier: "SettingsList",
            in: app
        )
        XCTAssertTrue(settingsList.waitForExistence(timeout: 10))

        let helpLink = UITestAppHarness.element(
            withIdentifier: "Settings_HelpLink",
            in: app
        )
        UITestAppHarness.scrollToElement(helpLink, in: settingsList)
        XCTAssertTrue(helpLink.waitForExistence(timeout: 5))
        helpLink.tap()

        let helpRoot = UITestAppHarness.element(
            withIdentifier: "HelpViewRoot",
            in: app
        )
        XCTAssertTrue(helpRoot.waitForExistence(timeout: 8))

        let privacyCell = app.staticTexts["Privacy Policy"]
        UITestAppHarness.scrollToElement(privacyCell, in: helpRoot)
        XCTAssertTrue(privacyCell.waitForExistence(timeout: 5))
        privacyCell.tap()

        XCTAssertTrue(app.navigationBars["Privacy Policy"].waitForExistence(timeout: 8))
        app.navigationBars.buttons.element(boundBy: 0).tap()

        XCTAssertTrue(helpRoot.waitForExistence(timeout: 8))
        app.navigationBars.buttons.element(boundBy: 0).tap()

        let aboutLink = UITestAppHarness.element(
            withIdentifier: "Settings_AboutLink",
            in: app
        )
        UITestAppHarness.scrollToElement(aboutLink, in: settingsList)
        XCTAssertTrue(aboutLink.waitForExistence(timeout: 5))
        aboutLink.tap()

        XCTAssertTrue(
            UITestAppHarness
                .element(withIdentifier: "AboutViewRoot", in: app)
                .waitForExistence(timeout: 8)
        )
        XCTAssertTrue(app.staticTexts["CycleOne"].exists)
    }

    @MainActor
    func testInsightsCompareAndHistoryWithSeededData() {
        let app = UITestAppHarness.launch(
            skipOnboarding: true,
            clearData: true,
            seedInsights: true
        )

        UITestAppHarness.waitForMainTabs(in: app)
        UITestAppHarness.openTab(at: 1, in: app)

        let insightsScrollView = app.scrollViews.firstMatch
        XCTAssertTrue(insightsScrollView.waitForExistence(timeout: 10))

        let compareLink = UITestAppHarness.element(
            withIdentifier: "Insights_CompareCyclesLink",
            in: app
        )
        UITestAppHarness.scrollToElement(compareLink, in: insightsScrollView)
        XCTAssertTrue(compareLink.waitForExistence(timeout: 8))
        compareLink.tap()

        XCTAssertTrue(
            UITestAppHarness
                .element(withIdentifier: "CycleComparisonViewRoot", in: app)
                .waitForExistence(timeout: 8)
        )
        XCTAssertTrue(app.staticTexts["Length Comparison"].exists)
        app.navigationBars.buttons.element(boundBy: 0).tap()

        let historyLink = UITestAppHarness.element(
            withIdentifier: "Insights_HistoryLink",
            in: app
        )
        UITestAppHarness.scrollToElement(historyLink, in: insightsScrollView)
        XCTAssertTrue(historyLink.waitForExistence(timeout: 8))
        historyLink.tap()

        XCTAssertTrue(
            UITestAppHarness
                .element(withIdentifier: "CycleHistoryListRoot", in: app)
                .waitForExistence(timeout: 8)
        )
        XCTAssertTrue(app.navigationBars["History"].exists)
    }

    @MainActor
    func testSettingsPredictionsAndNotificationsFlow() {
        let app = UITestAppHarness.launch(
            skipOnboarding: true,
            clearData: true,
            seedInsights: false
        )

        UITestAppHarness.waitForMainTabs(in: app)
        UITestAppHarness.openTab(at: 2, in: app)

        let settingsList = UITestAppHarness.element(
            withIdentifier: "SettingsList",
            in: app
        )
        XCTAssertTrue(settingsList.waitForExistence(timeout: 10))

        let predictionToggle = UITestAppHarness.element(
            withIdentifier: "Settings_EnablePredictionsToggle",
            in: app
        )
        XCTAssertTrue(predictionToggle.waitForExistence(timeout: 8))
        predictionToggle.tap()

        let notificationsLink = UITestAppHarness.element(
            withIdentifier: "Settings_NotificationsLink",
            in: app
        )
        UITestAppHarness.scrollToElement(notificationsLink, in: settingsList)
        XCTAssertTrue(notificationsLink.waitForExistence(timeout: 8))
        notificationsLink.tap()

        XCTAssertTrue(app.navigationBars["Notifications"].waitForExistence(timeout: 8))
        XCTAssertTrue(app.switches["Remind me before period"].exists)
        XCTAssertTrue(app.switches["Fertile window alerts"].exists)
    }
}
