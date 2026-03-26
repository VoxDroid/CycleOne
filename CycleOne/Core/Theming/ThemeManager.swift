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

enum AccentTheme: String, CaseIterable, Identifiable {
    case rose = "Rose"
    case lavender = "Lavender"
    case ocean = "Ocean"
    case sage = "Sage"
    case sunset = "Sunset"

    var id: String {
        rawValue
    }

    var accentColor: Color {
        switch self {
        case .rose: Color(red: 1.0, green: 0.42, blue: 0.62)
        case .lavender: Color(red: 0.69, green: 0.53, blue: 0.87)
        case .ocean: Color(red: 0.20, green: 0.56, blue: 0.82)
        case .sage: Color(red: 0.42, green: 0.68, blue: 0.55)
        case .sunset: Color(red: 0.93, green: 0.49, blue: 0.33)
        }
    }

    var icon: String {
        switch self {
        case .rose: "heart.fill"
        case .lavender: "sparkles"
        case .ocean: "drop.fill"
        case .sage: "leaf.fill"
        case .sunset: "sun.max.fill"
        }
    }
}

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var selectedTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(
                selectedTheme.rawValue,
                forKey: "selected_app_theme"
            )
        }
    }

    @Published var selectedAccent: AccentTheme {
        didSet {
            UserDefaults.standard.set(
                selectedAccent.rawValue,
                forKey: "selected_accent_theme"
            )
        }
    }

    init() {
        let themeRaw = UserDefaults.standard.string(
            forKey: "selected_app_theme"
        ) ?? AppTheme.system.rawValue
        self.selectedTheme = AppTheme(rawValue: themeRaw) ?? .system

        let accentRaw = UserDefaults.standard.string(
            forKey: "selected_accent_theme"
        ) ?? AccentTheme.rose.rawValue
        self.selectedAccent = AccentTheme(rawValue: accentRaw) ?? .rose
    }

    var accentColor: Color {
        selectedAccent.accentColor
    }
}
