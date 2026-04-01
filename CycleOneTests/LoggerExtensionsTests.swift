@testable import CycleOne
import OSLog
import XCTest

final class LoggerExtensionsTests: XCTestCase {
    func testLoggerStaticsAreAccessible() {
        _ = Logger.storage
        _ = Logger.viewCycle
        _ = Logger.notifications
        XCTAssertTrue(true)
    }
}
