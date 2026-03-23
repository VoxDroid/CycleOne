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

            Text("Insights View")
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }

            Text("Settings View")
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .accentColor(.pink)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
