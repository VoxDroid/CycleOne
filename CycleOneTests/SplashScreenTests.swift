import CoreData
@testable import CycleOne
import SwiftUI
import XCTest

final class SplashScreenTests: XCTestCase {
    func testSplashScreen_builds() {
        // onFinish closure is a no-op for tests
        host(SplashScreenView(onFinish: {}))
    }
}
