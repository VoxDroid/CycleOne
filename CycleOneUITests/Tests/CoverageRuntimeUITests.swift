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
            skipSplash: false
        )

        XCTAssertTrue(app.staticTexts["CycleOne"].waitForExistence(timeout: 4))
        XCTAssertTrue(app.staticTexts["Privacy-first period tracking"].exists)

        UITestAppHarness.waitForMainTabs(in: app)
    }

    @MainActor
    func testCalendarLogDayDeepInteractions() {
        let app = UITestAppHarness.launch(
            skipOnboarding: true,
            clearData: true,
            seedInsights: false
        )

        UITestAppHarness.waitForMainTabs(in: app)

        let logButton = app.buttons["Log Day"]
        XCTAssertTrue(logButton.waitForExistence(timeout: 8))
        logButton.tap()

        XCTAssertTrue(app.staticTexts["Log Day"].waitForExistence(timeout: 6))

        let heavyFlow = app.buttons["Flow_Heavy"]
        XCTAssertTrue(heavyFlow.waitForExistence(timeout: 4))
        heavyFlow.tap()

        let happyMood = UITestAppHarness.element(
            withIdentifier: "Log_Mood_Happy",
            in: app
        )
        XCTAssertTrue(happyMood.waitForExistence(timeout: 4))
        happyMood.tap()

        let highEnergy = UITestAppHarness.element(
            withIdentifier: "Log_Energy_High",
            in: app
        )
        XCTAssertTrue(highEnergy.waitForExistence(timeout: 4))
        highEnergy.tap()

        let painSlider = app.sliders["Log_PainSlider"]
        XCTAssertTrue(painSlider.waitForExistence(timeout: 4))
        painSlider.adjust(toNormalizedSliderPosition: 0.8)

        let crampsChip = UITestAppHarness.element(
            withIdentifier: "Symptom_Cramps",
            in: app
        )
        XCTAssertTrue(crampsChip.waitForExistence(timeout: 4))
        crampsChip.tap()

        let notesEditor = app.textViews["Log_NotesEditor"]
        XCTAssertTrue(notesEditor.waitForExistence(timeout: 4))
        notesEditor.tap()
        notesEditor.typeText("integration coverage note")

        let dismissButton = app.buttons["Dismiss"]
        if !dismissButton.waitForExistence(timeout: 2) {
            let returnKey = app.keyboards.buttons["return"]
            let doneKey = app.keyboards.buttons["Done"]
            if returnKey.waitForExistence(timeout: 1) {
                returnKey.tap()
            } else if doneKey.waitForExistence(timeout: 1) {
                doneKey.tap()
            } else {
                app.tap()
            }
        }
        if dismissButton.waitForExistence(timeout: 3) {
            dismissButton.tap()
            XCTAssertTrue(app.navigationBars["CycleOne"].waitForExistence(timeout: 8))
        }
    }

    @MainActor
    func testCalendarEditLogThenDeleteFlow() {
        let app = UITestAppHarness.launch(
            skipOnboarding: true,
            clearData: true,
            seedInsights: true
        )

        UITestAppHarness.waitForMainTabs(in: app)
        let editButton = app.buttons["Edit Log"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 8))
        editButton.tap()

        let deleteLogButton = app.buttons["Delete This Log"]
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
        let editButton = app.buttons["Edit Log"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 8))
        editButton.tap()

        let deleteLogButton = app.buttons["Delete This Log"]
        for _ in 0 ..< 3 where !deleteLogButton.exists {
            app.swipeUp()
        }
        XCTAssertTrue(deleteLogButton.waitForExistence(timeout: 6))
        deleteLogButton.tap()

        let cancelDeleteButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelDeleteButton.waitForExistence(timeout: 6))
        cancelDeleteButton.tap()

        XCTAssertTrue(app.staticTexts["Log Day"].waitForExistence(timeout: 6))
        let dismissButton = app.buttons["Dismiss"]
        XCTAssertTrue(dismissButton.waitForExistence(timeout: 6))
        dismissButton.tap()

        XCTAssertTrue(app.navigationBars["CycleOne"].waitForExistence(timeout: 8))
    }
}
