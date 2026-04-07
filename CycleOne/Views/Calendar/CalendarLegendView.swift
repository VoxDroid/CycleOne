//
//  CalendarLegendView.swift
//  CycleOne
//

import SwiftUI

struct CalendarLegendView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("calendar.legend.title")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            HStack(spacing: 0) {
                LegendItem(color: .systemPink, labelKey: "calendar.legend.period", isCustomView: true)
                Spacer()
                LegendItem(color: .systemGray, labelKey: "calendar.legend.predicted")
                Spacer()
                LegendItem(color: .systemTeal, labelKey: "calendar.legend.ovulation")
                Spacer()
                LegendItem(color: .systemTeal.withAlphaComponent(0.3), labelKey: "calendar.legend.fertile")
                Spacer()
                LegendItem(color: .secondaryLabel, labelKey: "calendar.legend.logged")
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
    let labelKey: LocalizedStringKey
    var isCustomView: Bool = false

    init(
        color: UIColor,
        labelKey: String,
        isCustomView: Bool = false
    ) {
        self.color = color
        self.labelKey = LocalizedStringKey(labelKey)
        self.isCustomView = isCustomView
    }

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Color(color))
                .frame(width: isCustomView ? 8 : 6, height: isCustomView ? 8 : 6)
            Text(labelKey)
                .font(.caption2)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    CalendarLegendView()
        .padding()
}
