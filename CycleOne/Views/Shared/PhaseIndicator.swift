//
//  PhaseIndicator.swift
//  CycleOne
//

import SwiftUI

struct PhaseIndicator: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let phase: String
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(phase)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.1))
        .cornerRadius(20)
    }
}
