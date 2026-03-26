//
//  CalendarLegendView.swift
//  CycleOne
//

import SwiftUI

struct CalendarLegendView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Calendar Legend")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            HStack(spacing: 0) {
                LegendItem(color: .systemPink, label: "Period", isCustomView: true)
                Spacer()
                LegendItem(color: .systemGray, label: "Predicted")
                Spacer()
                LegendItem(color: .systemTeal, label: "Ovulation")
                Spacer()
                LegendItem(color: .systemTeal.withAlphaComponent(0.3), label: "Fertile")
                Spacer()
                LegendItem(color: .secondaryLabel, label: "Logged")
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground).opacity(0.6))
        )
    }
}

struct LegendItem: View {
    let color: UIColor
    let label: String
    var isCustomView: Bool = false

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Color(color))
                .frame(width: isCustomView ? 8 : 6, height: isCustomView ? 8 : 6)
            Text(label)
                .font(.caption2)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    CalendarLegendView()
        .padding()
}
