//
//  SymptomGridView.swift
//  CycleOne
//

import SwiftUI

struct SymptomGridView: View {
    @Binding var selectedSymptoms: Set<String>
    let symptoms: [SymptomType]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            let categories = Array(Set(symptoms.map(\.category))).sorted(by: { $0.rawValue < $1.rawValue })

            ForEach(categories, id: \.self) { category in
                VStack(alignment: .leading, spacing: 8) {
                    Text(category.rawValue.capitalized)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)

                    FlowLayout(spacing: 8) {
                        ForEach(symptoms.filter { $0.category == category }) { symptom in
                            SymptomChip(
                                name: symptom.name,
                                isSelected: selectedSymptoms.contains(symptom.id)
                            ) {
                                if selectedSymptoms.contains(symptom.id) {
                                    selectedSymptoms.remove(symptom.id)
                                } else {
                                    selectedSymptoms.insert(symptom.id)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

struct SymptomChip: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Text(name)
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.themePeriod : Color(.secondarySystemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .onTapGesture {
                action()
            }
    }
}

/// Simple FlowLayout for chips
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > width {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            totalWidth = max(totalWidth, currentX)
        }
        return CGSize(width: totalWidth, height: currentY + lineHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var currentX: CGFloat = bounds.minX
        var currentY: CGFloat = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX {
                currentX = bounds.minX
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: .unspecified)
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}
