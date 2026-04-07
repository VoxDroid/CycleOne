@testable import CycleOne
import SwiftUI
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

    private final class PermissionRequestSpy {
        private(set) var requested = false

        func request() {
            requested = true
        }
    }

    func testPeriodReminderChange_callsPermissionWhenEnabled() {
        let view = NotificationSettingsView()
        let spy = PermissionRequestSpy()

        view.onPeriodReminderChanged(true, permissionRequester: spy.request)

        XCTAssertTrue(spy.requested)
    }

    func testPeriodReminderChange_skipsPermissionWhenDisabled() {
        let view = NotificationSettingsView()
        let spy = PermissionRequestSpy()

        view.onPeriodReminderChanged(false, permissionRequester: spy.request)

        XCTAssertFalse(spy.requested)
    }

    func testFertileReminderChange_callsPermissionWhenEnabled() {
        let view = NotificationSettingsView()
        let spy = PermissionRequestSpy()

        view.onFertileReminderChanged(true, permissionRequester: spy.request)

        XCTAssertTrue(spy.requested)
    }

    func testFertileReminderChange_skipsPermissionWhenDisabled() {
        let view = NotificationSettingsView()
        let spy = PermissionRequestSpy()

        view.onFertileReminderChanged(false, permissionRequester: spy.request)

        XCTAssertFalse(spy.requested)
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

    func testDaysLabel_handlesSingularAndPlural() {
        let defaults = UserDefaults.standard
        let previousValue = defaults.string(forKey: AppLanguage.storageKey)
        defer {
            if let previousValue {
                defaults.set(previousValue, forKey: AppLanguage.storageKey)
            } else {
                defaults.removeObject(forKey: AppLanguage.storageKey)
            }
        }

        defaults.set(AppLanguage.english.rawValue, forKey: AppLanguage.storageKey)

        XCTAssertEqual(NotificationSettingsView.daysLabel(for: 1), "1 day")
        XCTAssertEqual(NotificationSettingsView.daysLabel(for: 2), "2 days")
    }

    @MainActor
    func testDayPickerRow_buildsForCommonValues() {
        host(NotificationSettingsView.dayPickerRow(for: 1))
        host(NotificationSettingsView.dayPickerRow(for: 5))
        host(NotificationSettingsView.daysBeforePicker(selection: .constant(2)))
    }
}
