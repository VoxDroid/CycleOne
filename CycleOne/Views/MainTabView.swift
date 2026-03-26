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
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(0)
                .accessibilityIdentifier("CalendarTab")

            InsightsView(context: context)
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
                .tag(1)
                .accessibilityIdentifier("InsightsTab")

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
                .accessibilityIdentifier("SettingsTab")
        }
        .tint(.themeAccent)
    }
}
