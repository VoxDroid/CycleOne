//
//  CycleOneUITestsLaunchTests.swift
//  CycleOneUITests
//
//  Created by Drei on 3/23/26.
//

import XCTest

final class CycleOneUITestsLaunchTests: XCTestCase {
    override static var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testLaunch() {
        let app = XCUIApplication()
        app.launch()

        // Wait for splash screen to auto-dismiss
        sleep(3)

        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = "Launch Screen"
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
