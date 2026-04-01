@testable import CycleOne
import OSLog
import XCTest

final class LoggerExtensionsTests: XCTestCase {
    func testLoggerStaticsAreAccessible() {
        _ = Logger.storage
        _ = Logger.viewCycle
        _ = Logger.notifications

        Logger.storage.debug("storage logger test")
        Logger.viewCycle.info("viewCycle logger test")
        Logger.notifications.notice("notifications logger test")

        XCTAssertTrue(true)
    }
}
