//
//  Color+Theme.swift
//  CycleOne
//

import SwiftUI

extension Color {
    static let themePeriod = Color(red: 1.0, green: 0.42, blue: 0.62)
    static let themeFertile = Color(red: 0.69, green: 0.53, blue: 0.87)
    static let themeOvulation = Color(red: 0.58, green: 0.42, blue: 0.84)
    static var themeAccent: Color {
        ThemeManager.shared.selectedAccent.accentColor
    }

    static let themeBackground = Color(.systemGroupedBackground)
    static let themeCard = Color(.systemBackground)
}

enum Theme {
    static let cornerRadius: CGFloat = 16
    static let shadowRadius: CGFloat = 8
    static let animationDuration: Double = 0.3
    static let springDamping: Double = 0.7
    static let staggerDelay: Double = 0.08
}
