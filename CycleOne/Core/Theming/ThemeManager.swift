//
//  ThemeManager.swift
//  CycleOne
//

import Combine
import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String {
        rawValue
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

final class ThemeManager: ObservableObject {
    @AppStorage("selected_app_theme") var selectedTheme: AppTheme = .system
}
