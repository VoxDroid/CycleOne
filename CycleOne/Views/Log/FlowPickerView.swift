//
//  FlowPickerView.swift
//  CycleOne
//

import SwiftUI

struct FlowPickerView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var selection: FlowLevel

    var body: some View {
        HStack(spacing: 4) {
            ForEach(FlowLevel.allCases, id: \.self) { level in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = level
                    }
                }, label: {
                    VStack(spacing: 4) {
                        Image(systemName: level.icon)
                            .font(.system(size: 16))
                        Text(level.description)
                            .font(.caption2)
                            .fontWeight(
                                selection == level ? .bold : .regular
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        selection == level ?
                            Color.themeAccent : Color.clear
                    )
                    .foregroundColor(
                        selection == level ? .white : .primary
                    )
                    .cornerRadius(10)
                    .scaleEffect(selection == level ? 1.02 : 1.0)
                })
                .buttonStyle(.plain)
                .accessibilityIdentifier("Flow_\(level.accessibilityName)")
            }
        }
        .padding(4)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(
                    Color(.separator).opacity(0.3),
                    lineWidth: 0.5
                )
        )
    }
}
