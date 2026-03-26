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
                            HStack(spacing: 6) {
                                Text(
                                    days == 0 ?
                                        "Expected today" : "In"
                                )
                                if days > 0 {
                                    Text("\(days)")
                                        .font(.system(
                                            .title2,
                                            design: .rounded
                                        ))
                                        .fontWeight(.heavy)
                                        .foregroundColor(.themeAccent)
                                        .gentlePulse()
                                    Text("days")
                                }
                            }
                        }

                        if let ovDays = daysUntilOvulation,
                           ovDays >= 0
                        {
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .font(.caption)
                                    .foregroundColor(.themeFertile)
                                Text(
                                    "Ovulation: " +
                                        (ovDays == 0 ?
                                            "starts today" :
                                            "in \(ovDays) days")
                                )
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
                        Text("Irregular")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                    }
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "info.circle")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text("Predictions are estimates. Not medical advice.")
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
            return "Log your first period"
        }
        if days < 0 {
            return "Period is overdue"
        } else if days == 0 {
            return "Period starts today"
        } else {
            return "Next period"
        }
    }
}
