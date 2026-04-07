//
//  SymptomGridView.swift
//  CycleOne
//

import SwiftUI

struct SymptomGridView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var selectedSymptoms: Set<String>
    let symptoms: [SymptomType]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            let categories = Array(Set(symptoms.map(\.category))).sorted(by: {
                $0.localizedName < $1.localizedName
            })

            ForEach(categories, id: \.self) { category in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: category.icon)
                            .font(.caption)
                            .foregroundColor(category.color)
                        Text(category.localizedName)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                    }

                    FlowLayout(spacing: 8) {
                        ForEach(symptoms.filter { $0.category == category }) { symptom in
                            SymptomChip(
                                id: symptom.id,
                                localizedName: symptom.localizedName,
                                isSelected: selectedSymptoms.contains(symptom.id),
                                color: category.color
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    selectedSymptoms = Self.toggledSymptoms(
                                        current: selectedSymptoms,
                                        symptomID: symptom.id
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    static func toggledSymptoms(
        current: Set<String>,
        symptomID: String
    ) -> Set<String> {
        var updated = current
        if updated.contains(symptomID) {
            updated.remove(symptomID)
        } else {
            updated.insert(symptomID)
        }
        return updated
    }
}

struct SymptomChip: View {
    let id: String
    let localizedName: String
    let isSelected: Bool
    var color: Color = .themePeriod
    let action: () -> Void

    var body: some View {
        Text(localizedName)
            .font(.subheadline)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color(.secondarySystemBackground))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
            .scaleEffect(isSelected ? 1.05 : 1.0)
            .accessibilityIdentifier("Symptom_\(id)")
            .onTapGesture {
                action()
            }
    }
}

/// Simple FlowLayout for chips
struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let width = Self.resolvedWidth(for: proposal)
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

    static func resolvedWidth(for proposal: ProposedViewSize) -> CGFloat {
        proposal.width ?? .infinity
    }
}
