//
//  CycleHeaderView.swift
//  CycleOne
//

import SwiftUI

struct CycleHeaderView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let daysUntilPeriod: Int?
    let daysUntilOvulation: Int?
    let isIrregular: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "drop.fill")
                            .foregroundColor(.themeAccent)
                            .font(.title3)

                        Text(predictionText)
                            .font(.title3)
                            .fontWeight(.bold)
                    }

                    Group {
                        if let days = daysUntilPeriod {
                            Text(Self.periodCountdownText(days: days))
                        }

                        if let ovDays = daysUntilOvulation,
                           ovDays >= 0
                        {
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .font(.caption)
                                    .foregroundColor(.themeFertile)
                                Text(Self.ovulationText(days: ovDays))
                            }
                        }
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                Spacer()

                if isIrregular {
                    VStack(spacing: 4) {
                        Image(
                            systemName:
                            "exclamationmark.triangle.fill"
                        )
                        .foregroundColor(.yellow)
                        .font(.title3)
                        Text("calendar.header.irregular")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "info.circle")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("calendar.header.disclaimer")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
                .shadow(
                    color: Color.themeAccent.opacity(0.08),
                    radius: 10, x: 0, y: 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    Color.themeAccent.opacity(0.15),
                    lineWidth: 1
                )
        )
        .padding(.horizontal)
        .frame(minHeight: 120, alignment: .top)
    }

    private var predictionText: String {
        guard let days = daysUntilPeriod else {
            return L10n.string("calendar.header.log_first", default: "Log your first period")
        }
        if days < 0 {
            return L10n.string("calendar.header.overdue", default: "Period is overdue")
        } else if days == 0 {
            return L10n.string("calendar.header.starts_today", default: "Period starts today")
        } else {
            return L10n.string("calendar.header.next_period", default: "Next period")
        }
    }

    static func periodCountdownText(days: Int) -> String {
        switch days {
        case 0:
            L10n.string("calendar.header.expected_today", default: "Expected today")
        case let value where value < 0:
            L10n.format(
                "calendar.header.overdue_by_days",
                default: "Overdue by %d days",
                abs(value)
            )
        default:
            L10n.format("calendar.header.in_days", default: "In %d days", days)
        }
    }

    static func ovulationText(days: Int) -> String {
        if days == 0 {
            return L10n.string("calendar.header.ovulation_starts_today", default: "Ovulation starts today")
        }

        return L10n.format("calendar.header.ovulation_in_days", default: "Ovulation in %d days", days)
    }
}
