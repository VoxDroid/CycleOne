//
//  View+Extensions.swift
//  CycleOne
//

import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
    }

    func sectionHeaderStyle() -> some View {
        self
            .font(.caption)
            .fontWeight(.bold)
            .foregroundColor(.secondary)
            .textCase(.uppercase)
    }
}
