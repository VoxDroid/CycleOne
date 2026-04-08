import XCTest

enum UITestAppHarness {
    @MainActor
    static func launch(
        skipOnboarding: Bool,
        clearData: Bool,
        seedInsights: Bool,
        skipSplash: Bool = true,
        extraLaunchArguments: [String] = []
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments += ["-ui-testing"]

        if skipSplash {
            app.launchArguments += ["-ui-testing-skip-splash"]
        }

        if skipOnboarding {
            app.launchArguments += [
                "-ui-testing-has-seen-onboarding",
                "-hasSeenOnboarding", "YES",
            ]
        } else {
            app.launchArguments += [
                "-hasSeenOnboarding", "NO",
            ]
        }

        if clearData {
            app.launchArguments += ["-ui-testing-clear-data"]
        }

        if seedInsights {
            app.launchArguments += ["-ui-testing-seed-insights"]
        }

        if !extraLaunchArguments.isEmpty {
            app.launchArguments += extraLaunchArguments
        }

        app.launch()
        return app
    }

    @MainActor
    static func element(
        withIdentifier identifier: String,
        in app: XCUIApplication
    ) -> XCUIElement {
        app.descendants(matching: .any)
            .matching(identifier: identifier)
            .firstMatch
    }

    @MainActor
    static func openTab(at index: Int, in app: XCUIApplication) {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 25))
        XCTAssertTrue(waitForHittable(tabBar, timeout: 25))

        let tab = tabBar.buttons.element(boundBy: index)
        XCTAssertTrue(tab.waitForExistence(timeout: 12))
        XCTAssertTrue(waitForHittable(tab, timeout: 12))
        tab.tap()
    }

    @MainActor
    static func waitForMainTabs(in app: XCUIApplication) {
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 25))
        XCTAssertTrue(waitForHittable(tabBar, timeout: 25))
    }

    @MainActor
    static func waitForHittable(_ element: XCUIElement, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: "exists == true AND hittable == true")
        let expectation = XCTNSPredicateExpectation(
            predicate: predicate,
            object: element
        )
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    @MainActor
    static func scrollToElement(
        _ element: XCUIElement,
        in scrollView: XCUIElement,
        maxSwipes: Int = 8
    ) {
        var attempt = 0
        while !element.isHittable, attempt < maxSwipes {
            scrollView.swipeUp()
            attempt += 1
        }
    }
}
