//
//  FlowPickerView.swift
//  CycleOne
//

import SwiftUI

struct FlowPickerView: View {
    @Binding var selection: FlowLevel

    var body: some View {
        HStack(spacing: 0) {
            ForEach(FlowLevel.allCases, id: \.self) { level in
                Button(action: { selection = level }, label: {
                    VStack(spacing: 4) {
                        Text(level.description)
                            .font(.caption)
                            .fontWeight(selection == level ? .bold : .regular)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(selection == level ? Color.themePeriod : Color.clear)
                    .foregroundColor(selection == level ? .white : .primary)
                })
                .accessibilityIdentifier("Flow_\(level.description)")
            }
        }
        .background(Color(.systemGroupedBackground))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}
