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
                .accessibilityIdentifier("CalendarLegend_TitleLabel")

            HStack(spacing: 0) {
                LegendItem(
                    color: .systemPink,
                    labelKey: "calendar.legend.period",
                    isCustomView: true,
                    labelIdentifier: "CalendarLegend_PeriodLabel"
                )
                Spacer()
                LegendItem(
                    color: .systemGray,
                    labelKey: "calendar.legend.predicted",
                    labelIdentifier: "CalendarLegend_PredictedLabel"
                )
                Spacer()
                LegendItem(
                    color: .systemTeal,
                    labelKey: "calendar.legend.ovulation",
                    labelIdentifier: "CalendarLegend_OvulationLabel"
                )
                Spacer()
                LegendItem(
                    color: .systemTeal.withAlphaComponent(0.3),
                    labelKey: "calendar.legend.fertile",
                    labelIdentifier: "CalendarLegend_FertileLabel"
                )
                Spacer()
                LegendItem(
                    color: .secondaryLabel,
                    labelKey: "calendar.legend.logged",
                    labelIdentifier: "CalendarLegend_LoggedLabel"
                )
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground).opacity(0.6))
        )
        .accessibilityIdentifier("CalendarLegendView")
    }
}

struct LegendItem: View {
    let color: UIColor
    let labelKey: LocalizedStringKey
    var isCustomView: Bool = false
    let labelIdentifier: String

    init(
        color: UIColor,
        labelKey: String,
        isCustomView: Bool = false,
        labelIdentifier: String
    ) {
        self.color = color
        self.labelKey = LocalizedStringKey(labelKey)
        self.isCustomView = isCustomView
        self.labelIdentifier = labelIdentifier
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
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(labelIdentifier)
    }
}

#Preview {
    CalendarLegendView()
        .padding()
}
