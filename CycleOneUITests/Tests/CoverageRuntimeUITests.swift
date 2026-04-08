import XCTest

final class CoverageRuntimeUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testSplashScreenAppearsThenTransitionsToTabs() {
        let app = UITestAppHarness.launch(
            skipOnboarding: true,
            clearData: true,
            seedInsights: false,
            skipSplash: false,
            extraLaunchArguments: ["-ui-testing-splash-delay", "1"]
        )

        let splashRoot = UITestAppHarness.element(
            withIdentifier: "SplashScreenView",
            in: app
        )
        let splashTitle = app.staticTexts["CycleOne"]

        _ = splashRoot.waitForExistence(timeout: 12)
        _ = splashTitle.waitForExistence(timeout: 12)

        let splashGone = expectation(
            for: NSPredicate(format: "exists == false"),
            evaluatedWith: splashRoot
        )
        wait(for: [splashGone], timeout: 12)

        let tabs = app.tabBars.firstMatch
        XCTAssertTrue(tabs.waitForExistence(timeout: 12))
    }

    @MainActor
    func testCalendarLogDayDeepInteractions() {
        let app = UITestAppHarness.launch(
            skipOnboarding: true,
            clearData: true,
            seedInsights: false
        )

        UITestAppHarness.waitForMainTabs(in: app)

        let logButton = UITestAppHarness.element(
            withIdentifier: "Calendar_LogActionButton",
            in: app
        )
        XCTAssertTrue(logButton.waitForExistence(timeout: 8))
        logButton.tap()

        XCTAssertTrue(app.staticTexts["Log Day"].waitForExistence(timeout: 6))

        let heavyFlow = app.buttons["Flow_heavy"]
        XCTAssertTrue(heavyFlow.waitForExistence(timeout: 4))
        heavyFlow.tap()

        let happyMood = UITestAppHarness.element(
            withIdentifier: "Log_Mood_0",
            in: app
        )
        XCTAssertTrue(happyMood.waitForExistence(timeout: 4))
        happyMood.tap()

        let highEnergy = UITestAppHarness.element(
            withIdentifier: "Log_Energy_2",
            in: app
        )
        XCTAssertTrue(highEnergy.waitForExistence(timeout: 4))
        highEnergy.tap()

        let painSlider = app.sliders["Log_PainSlider"]
        XCTAssertTrue(painSlider.waitForExistence(timeout: 4))
        painSlider.adjust(toNormalizedSliderPosition: 0.8)

        let crampsChip = UITestAppHarness.element(
            withIdentifier: "Symptom_cramps",
            in: app
        )
        XCTAssertTrue(crampsChip.waitForExistence(timeout: 4))
        crampsChip.tap()

        let notesEditor = app.textViews["Log_NotesEditor"]
        XCTAssertTrue(notesEditor.waitForExistence(timeout: 4))
        notesEditor.tap()
        notesEditor.typeText("integration coverage note")

        app.tap()
        let dismissButton = UITestAppHarness.element(
            withIdentifier: "Log_DismissButton",
            in: app
        )
        XCTAssertTrue(dismissButton.waitForExistence(timeout: 6))
        dismissButton.tap()
        XCTAssertTrue(app.navigationBars["CycleOne"].waitForExistence(timeout: 8))
    }

    @MainActor
    func testCalendarEditLogThenDeleteFlow() {
        let app = UITestAppHarness.launch(
            skipOnboarding: true,
            clearData: true,
            seedInsights: true
        )

        UITestAppHarness.waitForMainTabs(in: app)
        let editButton = UITestAppHarness.element(
            withIdentifier: "Calendar_LogActionButton",
            in: app
        )
        XCTAssertTrue(editButton.waitForExistence(timeout: 8))
        editButton.tap()

        let deleteLogButton = UITestAppHarness.element(
            withIdentifier: "Log_DeleteThisLogButton",
            in: app
        )
        for _ in 0 ..< 3 where !deleteLogButton.exists {
            app.swipeUp()
        }
        XCTAssertTrue(deleteLogButton.waitForExistence(timeout: 6))
        deleteLogButton.tap()

        let confirmDeleteButton = app.buttons["Delete"]
        XCTAssertTrue(confirmDeleteButton.waitForExistence(timeout: 6))
        confirmDeleteButton.tap()

        XCTAssertTrue(app.navigationBars["CycleOne"].waitForExistence(timeout: 8))
    }

    @MainActor
    func testCalendarEditLogDeleteCancelFlow() {
        let app = UITestAppHarness.launch(
            skipOnboarding: true,
            clearData: true,
            seedInsights: true
        )

        UITestAppHarness.waitForMainTabs(in: app)
        let editButton = UITestAppHarness.element(
            withIdentifier: "Calendar_LogActionButton",
            in: app
        )
        XCTAssertTrue(editButton.waitForExistence(timeout: 8))
        editButton.tap()

        let deleteLogButton = UITestAppHarness.element(
            withIdentifier: "Log_DeleteThisLogButton",
            in: app
        )
        for _ in 0 ..< 3 where !deleteLogButton.exists {
            app.swipeUp()
        }
        XCTAssertTrue(deleteLogButton.waitForExistence(timeout: 6))
        deleteLogButton.tap()

        let cancelDeleteButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelDeleteButton.waitForExistence(timeout: 6))
        cancelDeleteButton.tap()

        XCTAssertTrue(app.staticTexts["Log Day"].waitForExistence(timeout: 6))
        let dismissButton = UITestAppHarness.element(
            withIdentifier: "Log_DismissButton",
            in: app
        )
        XCTAssertTrue(dismissButton.waitForExistence(timeout: 6))
        dismissButton.tap()

        XCTAssertTrue(app.navigationBars["CycleOne"].waitForExistence(timeout: 8))
    }
}
