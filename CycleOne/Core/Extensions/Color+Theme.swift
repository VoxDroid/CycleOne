//
//  Color+Theme.swift
//  CycleOne
//
//  Created by Antigravity on 3/23/26.
//

import SwiftUI

extension Color {
    static let themePeriod = Color.pink
    static let themeFertile = Color.purple
    static let themeOvulation = Color.purple.opacity(0.8)
    static let themeAccent = Color.pink
    static let themeBackground = Color(.systemGroupedBackground)
    static let themeCard = Color(.systemBackground)
}

enum Theme {
    static let cornerRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 5
}
