//
//  CycleOneApp.swift
//  CycleOne
//

import Combine
import CoreData
import SwiftUI

@main
struct CycleOneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared

    @StateObject private var themeManager = ThemeManager.shared
    @State private var showSplash = !ProcessInfo.processInfo.arguments.contains("-ui-testing-skip-splash")

    init() {
        UITestLaunchConfigurator.configureIfNeeded(
            context: persistenceController.container.viewContext
        )
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                MainTabView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(themeManager)
                    .preferredColorScheme(themeManager.selectedTheme.colorScheme)
                    .opacity(showSplash ? 0 : 1)

                if showSplash {
                    SplashScreenView {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showSplash = false
                        }
                    }
                    .environmentObject(themeManager)
                    .transition(.opacity)
                }
            }
        }
    }
}
