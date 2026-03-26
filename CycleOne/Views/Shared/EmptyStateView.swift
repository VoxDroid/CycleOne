//
//  EmptyStateView.swift
//  CycleOne
//

import SwiftUI

struct EmptyStateView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.themeAccent)
                .gentlePulse()

            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
