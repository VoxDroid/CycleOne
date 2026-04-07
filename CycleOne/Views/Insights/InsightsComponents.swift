//
//  InsightsComponents.swift
//  CycleOne
//

import SwiftUI

// MARK: - Cycle Length Trend Chart

struct CycleLengthChartView: View {
    let data: [(date: Date, length: Int)]

    private var maxLength: Int {
        Self.maxLength(for: data)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Cycle Length Trend")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(
                    Array(data.suffix(8).enumerated()),
                    id: \.offset
                ) { _, entry in
                    VStack(spacing: 4) {
                        Text("\(entry.length)")
                            .font(.system(
                                size: 10,
                                design: .rounded
                            ))
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.themeAccent)
                            .frame(
                                height: CGFloat(
                                    entry.length
                                ) / CGFloat(maxLength)
                                    * 100
                            )

                        Text(
                            entry.date.formatted(
                                .dateTime.month(.narrow)
                            )
                        )
                        .font(.system(size: 9))
                        .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 140)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
    }

    static func maxLength(for data: [(date: Date, length: Int)]) -> Int {
        data.map(\.length).max() ?? 35
    }
}

struct StatCard: View {
    let icon: String
    let title: LocalizedStringKey
    let value: String
    let unit: LocalizedStringKey
    let color: Color

    init(
        icon: String,
        title: String,
        value: String,
        unit: String,
        color: Color
    ) {
        self.icon = icon
        self.title = LocalizedStringKey(title)
        self.value = value
        self.unit = LocalizedStringKey(unit)
        self.color = color
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(
                    alignment: .firstTextBaseline,
                    spacing: 4
                ) {
                    Text(value)
                        .font(.system(
                            size: 28, weight: .bold,
                            design: .rounded
                        ))
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Color(.secondarySystemBackground))
                .shadow(
                    color: color.opacity(0.08),
                    radius: 8, x: 0, y: 4
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .stroke(color.opacity(0.15), lineWidth: 1)
        )
    }
}

struct MiniStatCard: View {
    let title: LocalizedStringKey
    let value: String
    let icon: String
    let color: Color

    init(
        title: String,
        value: String,
        icon: String,
        color: Color
    ) {
        self.title = LocalizedStringKey(title)
        self.value = value
        self.icon = icon
        self.color = color
    }

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

// MARK: - Mood Distribution

struct MoodDistributionView: View {
    let distribution: [String: Int]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Mood Distribution")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            let sortedMoods = distribution.sorted { $0.value > $1.value }
            let total = distribution.values.reduce(0, +)

            ForEach(sortedMoods, id: \.key) { mood in
                HStack(spacing: 12) {
                    Text(mood.key)
                        .font(.caption)
                        .frame(width: 60, alignment: .leading)

                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.themeAccent.opacity(0.7))
                            .frame(
                                width: Self.moodBarWidth(
                                    total: total,
                                    value: mood.value,
                                    availableWidth: geometry.size.width
                                )
                            )
                    }
                    .frame(height: 16)

                    Text("\(mood.value)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(width: 24, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
    }

    static func moodBarWidth(
        total: Int,
        value: Int,
        availableWidth: CGFloat
    ) -> CGFloat {
        guard total > 0 else { return 0 }
        return availableWidth * CGFloat(value) / CGFloat(total)
    }
}

// MARK: - Symptom Breakdown

struct SymptomBreakdownView: View {
    let symptoms: [(name: String, count: Int)]

    private var maxCount: Int {
        Self.maxCount(for: symptoms)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Top Symptoms")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)

            ForEach(
                Array(symptoms.prefix(5).enumerated()),
                id: \.offset
            ) { index, symptom in
                HStack(spacing: 8) {
                    Image(
                        systemName: Self.medalIcon(for: index)
                    )
                    .font(.caption)
                    .foregroundColor(
                        Self.medalColor(for: index)
                    )
                    .frame(width: 20)

                    Text(symptom.name)
                        .font(.caption)
                        .lineLimit(1)
                        .frame(
                            width: 80,
                            alignment: .leading
                        )

                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                Self.medalColor(for: index)
                                    .opacity(0.6)
                            )
                            .frame(
                                width: geometry.size
                                    .width
                                    * CGFloat(
                                        symptom.count
                                    )
                                    / CGFloat(maxCount)
                            )
                    }
                    .frame(height: 14)

                    Text("\(symptom.count)")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(width: 20, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: Theme.cornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
    }

    static func maxCount(for symptoms: [(name: String, count: Int)]) -> Int {
        symptoms.map(\.count).max() ?? 1
    }

    static func medalIcon(for index: Int) -> String {
        switch index {
        case 0: "1.circle.fill"
        case 1: "2.circle.fill"
        case 2: "3.circle.fill"
        default: "circle.fill"
        }
    }

    static func medalColor(for index: Int) -> Color {
        switch index {
        case 0: .themeAccent
        case 1: .themeFertile
        case 2: .orange
        default: .secondary
        }
    }
}
