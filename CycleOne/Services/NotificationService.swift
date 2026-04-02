//
//  NotificationService.swift
//  CycleOne
//
//  Created by Antigravity on 3/23/26.
//

import OSLog
import UserNotifications

@objc protocol NotificationCenterType: AnyObject {
    func requestAuthorization(
        options: UNAuthorizationOptions,
        completionHandler: @escaping @Sendable (Bool, Error?) -> Void
    )
    @objc(addNotificationRequest:withCompletionHandler:)
    func add(
        _ request: UNNotificationRequest,
        withCompletionHandler completionHandler: (@Sendable (Error?) -> Void)?
    )
    func removeAllPendingNotificationRequests()
}

extension UNUserNotificationCenter: NotificationCenterType {}

class NotificationService {
    static let shared = NotificationService()

    private var center: NotificationCenterType

    init(center: NotificationCenterType = UNUserNotificationCenter.current()) {
        self.center = center
    }

    // Testing helper: allow tests to swap the shared center to a mock to avoid
    // creating short-lived instances that can trigger deinit timing issues.
    #if DEBUG
        static func overrideSharedCenter(_ center: NotificationCenterType) {
            NotificationService.shared.center = center
        }
    #endif

    func requestAuthorization() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                Logger.notifications.info("Notification permission granted.")
            } else if let error {
                Logger.notifications.error("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    func schedulePeriodAlert(for date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "CycleOne"
        content.body = "Your period is predicted to start tomorrow."
        content.sound = .default

        let components = triggerComponents(for: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let dateString = ISO8601DateFormatter().string(from: date).prefix(10)
        let request = UNNotificationRequest(
            identifier: "period_alert_\(dateString)",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error {
                Logger.notifications.error("Failed to schedule period alert: \(error.localizedDescription)")
            }
        }
    }

    func scheduleFertileWindowAlert(for date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "CycleOne"
        content.body = "Your fertile window starts tomorrow."
        content.sound = .default

        let components = triggerComponents(for: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let dateString = ISO8601DateFormatter().string(from: date).prefix(10)
        let request = UNNotificationRequest(
            identifier: "fertile_alert_\(dateString)",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error {
                Logger.notifications.error("Failed to schedule fertile alert: \(error.localizedDescription)")
            }
        }
    }

    func triggerComponents(for date: Date) -> DateComponents {
        let triggerDate = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        var components = Calendar.current.dateComponents([.year, .month, .day], from: triggerDate)
        components.hour = 8
        components.minute = 0
        return components
    }

    func cancelAll() {
        center.removeAllPendingNotificationRequests()
    }

    /// Gracefully release external resources and replace the underlying
    /// `NotificationCenterType` with a no-op implementation. Useful for
    /// tests and for shutting down the shared service to avoid deinit-time
    /// race conditions with system objects.
    func shutdown() {
        // cancel any scheduled requests first
        cancelAll()
        // replace the center with a no-op implementation to avoid holding
        // references to system notification centre objects during deinit
        center = NoopNotificationCenter()
    }

    #if DEBUG
        /// Test helper to shutdown the shared singleton
        static func shutdownShared() {
            NotificationService.shared.shutdown()
        }
    #endif
}

/// A minimal, no-op notification center used to avoid releasing system
/// notification center internals during teardown.
private final class NoopNotificationCenter: NSObject, NotificationCenterType {
    func requestAuthorization(
        options: UNAuthorizationOptions,
        completionHandler: @escaping @Sendable (Bool, Error?) -> Void
    ) {
        completionHandler(true, nil)
    }

    @objc(addNotificationRequest:withCompletionHandler:)
    func add(
        _ request: UNNotificationRequest,
        withCompletionHandler completionHandler: (@Sendable (Error?) -> Void)?
    ) {
        completionHandler?(nil)
    }

    func removeAllPendingNotificationRequests() {
        // no-op
    }
}
