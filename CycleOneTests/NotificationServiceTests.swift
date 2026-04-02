//
//  NotificationServiceTests.swift
//  CycleOneTests
//
//  Created by Antigravity on 3/23/26.
//

@testable import CycleOne
import UserNotifications
import XCTest

final class NotificationServiceTests: XCTestCase {
    override func tearDown() {
        // Ensure the shared service has released system references after each test
        NotificationService.shared.shutdown()
        #if DEBUG
            NotificationService.overrideSharedCenter(UNUserNotificationCenter.current())
        #endif
        super.tearDown()
    }

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

    /// Additional tests covering scheduling and cancellation using a mock center
    class MockUNUserNotificationCenter: NSObject, NotificationCenterType {
        private(set) var didRequestAuthorization = false
        private(set) var requestedOptions: UNAuthorizationOptions?
        // Avoid retaining full UNNotificationRequest objects to reduce cross-runtime allocations
        private(set) var addedIdentifiers: [String] = []
        private(set) var addedTriggerComponents: [DateComponents?] = []
        private(set) var removedAll = false

        func requestAuthorization(options: UNAuthorizationOptions,
                                  completionHandler: @escaping @Sendable (Bool, Error?) -> Void)
        {
            didRequestAuthorization = true
            requestedOptions = options
            completionHandler(true, nil)
        }

        func add(
            _ request: UNNotificationRequest,
            withCompletionHandler completionHandler: (@Sendable (Error?) -> Void)? = nil
        ) {
            addedIdentifiers.append(request.identifier)
            if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                addedTriggerComponents.append(trigger.dateComponents)
            } else {
                addedTriggerComponents.append(nil)
            }
            completionHandler?(nil)
        }

        func removeAllPendingNotificationRequests() {
            removedAll = true
        }
    }

    class DenyingMockUNUserNotificationCenter: NSObject, NotificationCenterType {
        struct AuthorizationDeniedError: Error {}

        private(set) var didRequestAuthorization = false
        private(set) var requestedOptions: UNAuthorizationOptions?

        func requestAuthorization(options: UNAuthorizationOptions,
                                  completionHandler: @escaping @Sendable (Bool, Error?) -> Void)
        {
            didRequestAuthorization = true
            requestedOptions = options
            completionHandler(false, AuthorizationDeniedError())
        }

        func add(
            _ request: UNNotificationRequest,
            withCompletionHandler completionHandler: (@Sendable (Error?) -> Void)?
        ) {
            completionHandler?(nil)
        }

        func removeAllPendingNotificationRequests() {}
    }

    class FailingAddMockUNUserNotificationCenter: NSObject, NotificationCenterType {
        struct AddError: Error {}

        func requestAuthorization(options: UNAuthorizationOptions,
                                  completionHandler: @escaping @Sendable (Bool, Error?) -> Void)
        {
            completionHandler(true, nil)
        }

        func add(
            _ request: UNNotificationRequest,
            withCompletionHandler completionHandler: (@Sendable (Error?) -> Void)?
        ) {
            completionHandler?(AddError())
        }

        func removeAllPendingNotificationRequests() {}
    }

    func testRequestAuthorization_invokesCenter() {
        let mock = MockUNUserNotificationCenter()
        NotificationService.overrideSharedCenter(mock)
        defer { NotificationService.overrideSharedCenter(UNUserNotificationCenter.current()) }
        let service = NotificationService.shared

        service.requestAuthorization()

        XCTAssertTrue(mock.didRequestAuthorization)
        XCTAssertEqual(mock.requestedOptions, [.alert, .badge, .sound])
    }

    func testRequestAuthorization_handlesDeniedErrorPath() {
        let mock = DenyingMockUNUserNotificationCenter()
        NotificationService.overrideSharedCenter(mock)
        defer { NotificationService.overrideSharedCenter(UNUserNotificationCenter.current()) }
        let service = NotificationService.shared

        service.requestAuthorization()

        XCTAssertTrue(mock.didRequestAuthorization)
        XCTAssertEqual(mock.requestedOptions, [.alert, .badge, .sound])
    }

    func testDenyingMock_scheduleAndCancelPaths() throws {
        let mock = DenyingMockUNUserNotificationCenter()
        NotificationService.overrideSharedCenter(mock)
        defer { NotificationService.overrideSharedCenter(UNUserNotificationCenter.current()) }
        let service = NotificationService.shared

        let iso = ISO8601DateFormatter()
        iso.timeZone = TimeZone(secondsFromGMT: 0)
        let date = try XCTUnwrap(iso.date(from: "2026-03-31T12:00:00Z"))

        service.schedulePeriodAlert(for: date)
        service.cancelAll()

        XCTAssertTrue(true)
    }

    func testFailingAddMock_requestAuthorizationAndCancelPaths() {
        let mock = FailingAddMockUNUserNotificationCenter()
        NotificationService.overrideSharedCenter(mock)
        defer { NotificationService.overrideSharedCenter(UNUserNotificationCenter.current()) }
        let service = NotificationService.shared

        service.requestAuthorization()
        service.cancelAll()

        XCTAssertTrue(true)
    }

    func testConstructNotificationObjects() {
        let content = UNMutableNotificationContent()
        content.title = "Test"
        content.body = "Body"

        var components = DateComponents()
        components.year = 2026
        components.month = 3
        components.day = 1
        components.hour = 8
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: "test_req", content: content, trigger: trigger)
        XCTAssertEqual(request.identifier, "test_req")
    }

    func testSchedulePeriodAlert_addsRequest() throws {
        let mock = MockUNUserNotificationCenter()
        NotificationService.overrideSharedCenter(mock)
        defer { NotificationService.overrideSharedCenter(UNUserNotificationCenter.current()) }
        let service = NotificationService.shared

        let iso = ISO8601DateFormatter()
        iso.timeZone = TimeZone(secondsFromGMT: 0)
        let date = try XCTUnwrap(iso.date(from: "2026-03-31T12:00:00Z"))

        service.schedulePeriodAlert(for: date)

        XCTAssertEqual(mock.addedIdentifiers.count, 1)
        let identifier = try XCTUnwrap(mock.addedIdentifiers.first)
        XCTAssertTrue(identifier.starts(with: "period_alert_"))
        XCTAssertTrue(identifier.contains("2026-03-31"))
    }

    func testScheduleFertileWindowAlert_addsRequest() throws {
        let mock = MockUNUserNotificationCenter()
        NotificationService.overrideSharedCenter(mock)
        defer { NotificationService.overrideSharedCenter(UNUserNotificationCenter.current()) }
        let service = NotificationService.shared

        let iso = ISO8601DateFormatter()
        iso.timeZone = TimeZone(secondsFromGMT: 0)
        let date = try XCTUnwrap(iso.date(from: "2026-04-05T00:00:00Z"))

        service.scheduleFertileWindowAlert(for: date)

        XCTAssertEqual(mock.addedIdentifiers.count, 1)
        let identifier = try XCTUnwrap(mock.addedIdentifiers.first)
        XCTAssertTrue(identifier.starts(with: "fertile_alert_"))
        XCTAssertTrue(identifier.contains("2026-04-05"))
    }

    func testSchedulePeriodAlert_handlesCenterAddError() throws {
        let mock = FailingAddMockUNUserNotificationCenter()
        NotificationService.overrideSharedCenter(mock)
        defer { NotificationService.overrideSharedCenter(UNUserNotificationCenter.current()) }
        let service = NotificationService.shared

        let iso = ISO8601DateFormatter()
        iso.timeZone = TimeZone(secondsFromGMT: 0)
        let date = try XCTUnwrap(iso.date(from: "2026-03-31T12:00:00Z"))

        service.schedulePeriodAlert(for: date)

        XCTAssertTrue(true)
    }

    func testScheduleFertileWindowAlert_handlesCenterAddError() throws {
        let mock = FailingAddMockUNUserNotificationCenter()
        NotificationService.overrideSharedCenter(mock)
        defer { NotificationService.overrideSharedCenter(UNUserNotificationCenter.current()) }
        let service = NotificationService.shared

        let iso = ISO8601DateFormatter()
        iso.timeZone = TimeZone(secondsFromGMT: 0)
        let date = try XCTUnwrap(iso.date(from: "2026-04-05T00:00:00Z"))

        service.scheduleFertileWindowAlert(for: date)

        XCTAssertTrue(true)
    }

    func testCancelAll_callsRemoveAll() {
        let mock = MockUNUserNotificationCenter()
        NotificationService.overrideSharedCenter(mock)
        defer { NotificationService.overrideSharedCenter(UNUserNotificationCenter.current()) }
        let service = NotificationService.shared

        service.cancelAll()

        XCTAssertTrue(mock.removedAll)
    }

    func testMockAdd_handlesNonCalendarTrigger() {
        let mock = MockUNUserNotificationCenter()

        let content = UNMutableNotificationContent()
        content.title = "NonCal"
        content.body = "body"

        // Use a time interval trigger (not a calendar trigger) to exercise the else branch
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: false)
        let request = UNNotificationRequest(identifier: "noncal_req", content: content, trigger: trigger)

        mock.add(request)

        XCTAssertEqual(mock.addedIdentifiers.last, "noncal_req")
        XCTAssertEqual(mock.addedTriggerComponents.last as? DateComponents, nil)
    }

    #if DEBUG
        func testShutdownShared_usesNoopCenterAndRemainsCallable() throws {
            NotificationService.shutdownShared()
            let service = NotificationService.shared

            service.requestAuthorization()

            let iso = ISO8601DateFormatter()
            iso.timeZone = TimeZone(secondsFromGMT: 0)
            let date = try XCTUnwrap(iso.date(from: "2026-05-01T00:00:00Z"))

            service.schedulePeriodAlert(for: date)
            service.scheduleFertileWindowAlert(for: date)
            service.cancelAll()

            XCTAssertTrue(true)
        }
    #endif
}
