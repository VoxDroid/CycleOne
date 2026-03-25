//
//  CalendarLegendView.swift
//  CycleOne
//

import SwiftUI

struct CalendarLegendView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Calendar Legend")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 16) {
                    LegendItem(color: .systemPink, label: "Period", isCustomView: true)
                    LegendItem(color: .systemGray, label: "Predicted Period")
                }
                HStack(spacing: 16) {
                    LegendItem(color: .systemTeal, label: "Ovulation Day")
                    LegendItem(color: .systemTeal.withAlphaComponent(0.3), label: "Fertile Window")
                }
                LegendItem(color: .secondaryLabel, label: "Logged (Mood/Symptom)")
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground).opacity(0.5))
        .cornerRadius(12)
    }
}

struct LegendItem: View {
    let color: UIColor
    let label: String
    var isCustomView: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(color))
                .frame(width: isCustomView ? 10 : 6, height: isCustomView ? 10 : 6)
            Text(label)
                .font(.caption)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    CalendarLegendView()
        .padding()
}
