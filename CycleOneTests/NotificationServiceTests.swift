//
//  NotificationServiceTests.swift
//  CycleOneTests
//
//  Created by Antigravity on 3/23/26.
//

@testable import CycleOne
import XCTest

final class NotificationServiceTests: XCTestCase {
    func testTriggerComponentsCalculation() throws {
        let service = NotificationService.shared

        // Given a date (e.g., March 25, 2026)
        var components = DateComponents()
        components.year = 2026
        components.month = 3
        components.day = 25
        let targetDate = try XCTUnwrap(Calendar.current.date(from: components))

        // When calculating trigger components
        let trigger = service.triggerComponents(for: targetDate)

        // Then it should be for the previous day at 8:00 AM
        XCTAssertEqual(trigger.year, 2026)
        XCTAssertEqual(trigger.month, 3)
        XCTAssertEqual(trigger.day, 24)
        XCTAssertEqual(trigger.hour, 8)
        XCTAssertEqual(trigger.minute, 0)
    }
}
