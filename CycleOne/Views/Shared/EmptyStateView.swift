//
//  EmptyStateView.swift
//  CycleOne
//

import SwiftUI

struct EmptyStateView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let icon: String
    let title: LocalizedStringKey
    let message: LocalizedStringKey

    init(icon: String, title: String, message: String) {
        self.icon = icon
        self.title = LocalizedStringKey(title)
        self.message = LocalizedStringKey(message)
    }

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
