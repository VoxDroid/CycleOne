//
//  PillBadge.swift
//  CycleOne
//

import SwiftUI

struct PillBadge: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.bold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}
