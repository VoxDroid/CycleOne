@testable import CycleOne
import UserNotifications
import XCTest

final class NotificationSettingsViewLogicTests: XCTestCase {
    private final class MockAuthorizationCenter: NotificationAuthorizationCenter {
        private(set) var callCount = 0
        private(set) var lastOptions: UNAuthorizationOptions?
        var granted = true

        func requestAuthorization(
            options: UNAuthorizationOptions,
            completionHandler: @escaping @Sendable (Bool, Error?) -> Void
        ) {
            callCount += 1
            lastOptions = options
            completionHandler(granted, nil)
        }
    }

    func testPeriodReminderChange_callsPermissionWhenEnabled() {
        let view = NotificationSettingsView()
        var requested = false

        view.onPeriodReminderChanged(true) {
            requested = true
        }

        XCTAssertTrue(requested)
    }

    func testPeriodReminderChange_skipsPermissionWhenDisabled() {
        let view = NotificationSettingsView()
        var requested = false

        view.onPeriodReminderChanged(false) {
            requested = true
        }

        XCTAssertFalse(requested)
    }

    func testFertileReminderChange_callsPermissionWhenEnabled() {
        let view = NotificationSettingsView()
        var requested = false

        view.onFertileReminderChanged(true) {
            requested = true
        }

        XCTAssertTrue(requested)
    }

    func testFertileReminderChange_skipsPermissionWhenDisabled() {
        let view = NotificationSettingsView()
        var requested = false

        view.onFertileReminderChanged(false) {
            requested = true
        }

        XCTAssertFalse(requested)
    }

    func testRequestPermission_usesInjectedCenter() {
        let view = NotificationSettingsView()
        let center = MockAuthorizationCenter()

        view.requestPermission(center: center)

        XCTAssertEqual(center.callCount, 1)
        XCTAssertEqual(center.lastOptions, [.alert, .sound, .badge])
    }

    func testRequestPermission_deniedBranchStillInvokesCenter() {
        let view = NotificationSettingsView()
        let center = MockAuthorizationCenter()
        center.granted = false

        view.requestPermission(center: center)

        XCTAssertEqual(center.callCount, 1)
    }

    func testDaysBeforeAndUpdateNotifications_noCrash() {
        let view = NotificationSettingsView()

        view.onDaysBeforePeriodChanged()
        view.updateNotifications()

        XCTAssertTrue(true)
    }

    func testTwoArgumentHandlers_noCrash() {
        let view = NotificationSettingsView()

        view.handlePeriodReminderChange(false, true)
        view.handleDaysBeforePeriodChange(1, 3)
        view.handleFertileReminderChange(false, true)

        XCTAssertTrue(true)
    }
}
