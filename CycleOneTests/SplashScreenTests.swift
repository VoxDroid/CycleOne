import CoreData
@testable import CycleOne
import SwiftUI
import XCTest

final class SplashScreenTests: XCTestCase {
    func testSplashScreen_builds() {
        // onFinish closure is a no-op for tests
        host(SplashScreenView(onFinish: {}))
    }

    func testSplashScreen_instantiationAndBodyEvaluation() {
        let view = SplashScreenView(onFinish: {})
        _ = view.body
        XCTAssertTrue(true)
    }
}
