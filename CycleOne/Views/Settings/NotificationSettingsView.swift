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
            Section(header: Text("settings.notifications.section.period")) {
                Toggle("settings.notifications.toggle.period", isOn: $remindBeforePeriod)
                    .accessibilityIdentifier("Notifications_PeriodToggle")
                    .onChange(of: remindBeforePeriod, initial: false, handlePeriodReminderChange)

                if remindBeforePeriod {
                    Self.daysBeforePicker(selection: $daysBeforePeriod)
                        .accessibilityIdentifier("Notifications_DaysBeforePicker")
                        .onChange(of: daysBeforePeriod, initial: false, handleDaysBeforePeriodChange)
                }
            }

            Section(header: Text("settings.notifications.section.fertile")) {
                Toggle("settings.notifications.toggle.fertile", isOn: $remindBeforeFertile)
                    .accessibilityIdentifier("Notifications_FertileToggle")
                    .onChange(of: remindBeforeFertile, initial: false, handleFertileReminderChange)
            }

            Section(footer: Text("settings.notifications.footer")) {
                EmptyView()
            }
        }
        .accessibilityIdentifier("NotificationSettingsViewRoot")
        .navigationTitle("settings.notifications.title")
    }

    static func daysLabel(for day: Int) -> String {
        switch day {
        case 1:
            return AppLanguage.localizedString(
                "settings.notifications.days.1",
                defaultValue: "1 day"
            )
        case 2:
            return AppLanguage.localizedString(
                "settings.notifications.days.2",
                defaultValue: "2 days"
            )
        case 3:
            return AppLanguage.localizedString(
                "settings.notifications.days.3",
                defaultValue: "3 days"
            )
        case 5:
            return AppLanguage.localizedString(
                "settings.notifications.days.5",
                defaultValue: "5 days"
            )
        default:
            let format = AppLanguage.localizedString(
                "settings.notifications.days.format",
                defaultValue: "%d days"
            )
            return String(format: format, day)
        }
    }

    @MainActor
    static func dayPickerRow(for day: Int) -> some View {
        Text(daysLabel(for: day)).tag(day)
    }

    @MainActor
    static func daysBeforePicker(selection: Binding<Int>) -> some View {
        Picker("settings.notifications.days_before", selection: selection) {
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
