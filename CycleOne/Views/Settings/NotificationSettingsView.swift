//
//  NotificationSettingsView.swift
//  CycleOne
//

import SwiftUI
import UserNotifications

protocol NotificationAuthorizationCenter {
    func requestAuthorization(
        options: UNAuthorizationOptions,
        completionHandler: @escaping @Sendable (Bool, Error?) -> Void
    )
}

extension UNUserNotificationCenter: NotificationAuthorizationCenter {}

struct NotificationSettingsView: View {
    @AppStorage("remindBeforePeriod") private var remindBeforePeriod = false
    @AppStorage("remindBeforeFertile") private var remindBeforeFertile = false
    @AppStorage("daysBeforePeriod") private var daysBeforePeriod = 1

    var body: some View {
        List {
            Section(header: Text("Period Reminders")) {
                Toggle("Remind me before period", isOn: $remindBeforePeriod)
                    .accessibilityIdentifier("Notifications_PeriodToggle")
                    .onChange(of: remindBeforePeriod, initial: false, handlePeriodReminderChange)

                if remindBeforePeriod {
                    Self.daysBeforePicker(selection: $daysBeforePeriod)
                        .accessibilityIdentifier("Notifications_DaysBeforePicker")
                        .onChange(of: daysBeforePeriod, initial: false, handleDaysBeforePeriodChange)
                }
            }

            Section(header: Text("Fertile Window")) {
                Toggle("Fertile window alerts", isOn: $remindBeforeFertile)
                    .accessibilityIdentifier("Notifications_FertileToggle")
                    .onChange(of: remindBeforeFertile, initial: false, handleFertileReminderChange)
            }

            Section(footer: Text("Notifications are scheduled locally on your device at 8:00 AM.")) {
                EmptyView()
            }
        }
        .accessibilityIdentifier("NotificationSettingsViewRoot")
        .navigationTitle("Notifications")
    }

    static func daysLabel(for day: Int) -> String {
        "\(day) day\(day > 1 ? "s" : "")"
    }

    @MainActor
    static func dayPickerRow(for day: Int) -> some View {
        Text(daysLabel(for: day)).tag(day)
    }

    @MainActor
    static func daysBeforePicker(selection: Binding<Int>) -> some View {
        Picker("Days before", selection: selection) {
            dayPickerRow(for: 1)
            dayPickerRow(for: 2)
            dayPickerRow(for: 3)
            dayPickerRow(for: 5)
        }
    }

    func onPeriodReminderChanged(
        _ newValue: Bool,
        permissionRequester: (() -> Void)? = nil
    ) {
        if newValue { (permissionRequester ?? { requestPermission() })() }
        updateNotifications()
    }

    func handlePeriodReminderChange(_ oldValue: Bool, _ newValue: Bool) {
        onPeriodReminderChanged(newValue)
    }

    func onDaysBeforePeriodChanged() {
        updateNotifications()
    }

    func handleDaysBeforePeriodChange(_ oldValue: Int, _ newValue: Int) {
        onDaysBeforePeriodChanged()
    }

    func onFertileReminderChanged(
        _ newValue: Bool,
        permissionRequester: (() -> Void)? = nil
    ) {
        if newValue { (permissionRequester ?? { requestPermission() })() }
        updateNotifications()
    }

    func handleFertileReminderChange(_ oldValue: Bool, _ newValue: Bool) {
        onFertileReminderChanged(newValue)
    }

    func requestPermission(
        center: NotificationAuthorizationCenter = UNUserNotificationCenter.current()
    ) {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if !granted {
                // Handle denied permission
            }
        }
    }

    func updateNotifications() {
        // This should trigger the NotificationService via a ViewModel
        // For now, I'll rely on CycleViewModel to reschedule on changes.
    }
}
