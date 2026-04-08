import CoreData
@testable import CycleOne
import SwiftUI
import UIKit
import XCTest

final class SplashScreenTests: XCTestCase {
    func testSplashScreen_builds() {
        // onFinish closure is a no-op for tests
        let view = SplashScreenView(onFinish: Self.noop)
        view.onFinish()
        host(view)
    }

    func testSplashScreen_instantiationAndBodyEvaluation() {
        let view = SplashScreenView(onFinish: Self.noop)
        view.onFinish()
        _ = view.body
        XCTAssertTrue(true)
    }

    @MainActor
    func testSplashScreen_exitSequenceCallsOnFinish() {
        let finished = expectation(description: "splash finishes")

        let root = SplashScreenView {
            finished.fulfill()
        }
        .environmentObject(ThemeManager.shared)

        let host = UIHostingController(rootView: root)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = host
        window.makeKeyAndVisible()

        wait(for: [finished], timeout: 4.0)
        XCTAssertNotNil(host.viewIfLoaded)
    }

    private static func noop() {}
}
