//
//  MainTabView.swift
//  CycleOne
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = CycleViewModel()

    var body: some View {
        TabView {
            CalendarView(viewModel: viewModel)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .accessibilityIdentifier("CalendarTab")

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
                .accessibilityIdentifier("InsightsTab")

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .accessibilityIdentifier("SettingsTab")
        }
        .accentColor(.pink)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
