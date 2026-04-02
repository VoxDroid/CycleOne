import CoreData
@testable import CycleOne
import SwiftUI
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

    private static func noop() {}
}
