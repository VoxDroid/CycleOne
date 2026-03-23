//
//  NotificationSettingsView.swift
//  CycleOne
//

import SwiftUI

struct NotificationSettingsView: View {
    @AppStorage("remindBeforePeriod") private var remindBeforePeriod = false
    @AppStorage("remindBeforeFertile") private var remindBeforeFertile = false
    @AppStorage("daysBeforePeriod") private var daysBeforePeriod = 1

    var body: some View {
        List {
            Section(header: Text("Period Reminders")) {
                Toggle("Remind me before period", isOn: $remindBeforePeriod)
                    .onChange(of: remindBeforePeriod) { _, newValue in
                        if newValue { requestPermission() }
                        updateNotifications()
                    }

                if remindBeforePeriod {
                    Picker("Days before", selection: $daysBeforePeriod) {
                        ForEach([1, 2, 3, 5], id: \.self) { day in
                            Text("\(day) day\(day > 1 ? "s" : "")").tag(day)
                        }
                    }
                    .onChange(of: daysBeforePeriod) { _, _ in
                        updateNotifications()
                    }
                }
            }

            Section(header: Text("Fertile Window")) {
                Toggle("Fertile window alerts", isOn: $remindBeforeFertile)
                    .onChange(of: remindBeforeFertile) { _, newValue in
                        if newValue { requestPermission() }
                        updateNotifications()
                    }
            }

            Section(footer: Text("Notifications are scheduled locally on your device at 8:00 AM.")) {
                EmptyView()
            }
        }
        .navigationTitle("Notifications")
    }

    private func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if !granted {
                // Handle denied permission
            }
        }
    }

    private func updateNotifications() {
        // This should trigger the NotificationService via a ViewModel
        // For now, I'll rely on CycleViewModel to reschedule on changes.
    }
}
