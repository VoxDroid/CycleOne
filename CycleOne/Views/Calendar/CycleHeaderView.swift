//
//  CycleHeaderView.swift
//  CycleOne
//

import SwiftUI

struct CycleHeaderView: View {
    let daysUntilPeriod: Int?
    let isIrregular: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(predictionText)
                        .font(.title2)
                        .fontWeight(.bold)

                    if let days = daysUntilPeriod {
                        Text(days == 0 ? "Expected today" : "In \(days) days")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()

                if isIrregular {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.yellow)
                        .help("Cycles vary by more than 10 days.")
                }
            }

            Text("ⓘ Predictions are estimates only. Not medical advice.")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .padding(.horizontal)
        .frame(minHeight: 100, alignment: .top)
    }

    private var predictionText: String {
        guard let days = daysUntilPeriod else {
            return "Log your first period to see predictions"
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
