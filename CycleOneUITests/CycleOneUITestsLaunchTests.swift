//
//  CycleOneUITestsLaunchTests.swift
//  CycleOneUITests
//
//  Created by Drei on 3/23/26.
//

import XCTest

final class CycleOneUITestsLaunchTests: XCTestCase {
    override static var runsForEachTargetApplicationUIConfiguration: Bool {
        false
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() {
        let app = UITestAppHarness.launch(
            skipOnboarding: true,
            clearData: false,
            seedInsights: false,
            extraLaunchArguments: ["-ui-testing-language", "en"]
        )

        UITestAppHarness.waitForMainTabs(in: app)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
