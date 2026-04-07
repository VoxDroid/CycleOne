//
//  MainTabView.swift
//  CycleOne
//

import CoreData
import SwiftUI

struct MainTabView: View {
    @Environment(\.managedObjectContext) var context
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CalendarView(context: context)
                .tabItem {
                    Label("tab.calendar", systemImage: "calendar")
                }
                .tag(0)
                .accessibilityIdentifier("CalendarTab")

            InsightsView(context: context)
                .tabItem {
                    Label("tab.insights", systemImage: "chart.bar.fill")
                }
                .tag(1)
                .accessibilityIdentifier("InsightsTab")

            SettingsView()
                .tabItem {
                    Label("tab.settings", systemImage: "gear")
                }
                .tag(2)
                .accessibilityIdentifier("SettingsTab")
        }
        .tint(.themeAccent)
    }
}
