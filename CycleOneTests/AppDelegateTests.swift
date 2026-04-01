@testable import CycleOne
import UIKit
import UserNotifications
import XCTest

final class AppDelegateTests: XCTestCase {
    func testDidFinishLaunchingSetsNotificationCenterDelegateAndReturnsTrue() {
        let appDelegate = AppDelegate()
        let center = UNUserNotificationCenter.current()
        let previousDelegate = center.delegate
        defer { center.delegate = previousDelegate }

        let didFinish = appDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)

        XCTAssertTrue(didFinish)
        XCTAssertTrue(center.delegate === appDelegate)
    }
}
