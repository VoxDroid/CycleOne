//
//  NotificationService.swift
//  CycleOne
//
//  Created by Antigravity on 3/23/26.
//

import OSLog
import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
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

        let triggerDate = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "period_alert", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
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

        let triggerDate = Calendar.current.date(byAdding: .day, value: -1, to: date) ?? date
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "fertile_alert", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                Logger.notifications.error("Failed to schedule fertile alert: \(error.localizedDescription)")
            }
        }
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
