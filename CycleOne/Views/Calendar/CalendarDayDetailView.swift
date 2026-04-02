//
//  CalendarDayDetailView.swift
//  CycleOne
//

import SwiftUI

struct CalendarDayDetailView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let date: Date
    let log: DayLog?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(date.formatted(
                        date: .complete, time: .omitted
                    ))
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    if let log, log.flowLevel > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "drop.fill")
                                .font(.caption)
                                .foregroundColor(.themePeriod)
                            Text(Self.flowDescription(for: log.flowLevel))
                                .font(.headline)
                                .foregroundColor(.themePeriod)
                        }
                    } else {
                        Text("No Period Logged")
                            .font(.headline)
                    }
                }

                Spacer()

                NavigationLink(value: date) {
                    HStack(spacing: 4) {
                        Image(
                            systemName: log == nil ?
                                "plus.circle.fill" :
                                "pencil.circle.fill"
                        )
                        Text(log == nil ? "Log Day" : "Edit Log")
                    }
                    .font(.footnote)
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.themeAccent)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .shadow(
                        color: Color.themeAccent.opacity(0.3),
                        radius: 6, x: 0, y: 3
                    )
                }
            }

            if let log {
                HStack(spacing: 12) {
                    if log.mood > 0 {
                        DetailChip(
                            icon: Self.moodIcon(for: log.mood),
                            label: Self.moodDescription(for: log.mood),
                            color: .themeAccent
                        )
                    }
                    if log.energyLevel > 0 {
                        EnergyHighlight(
                            level: Self.energyLevel(for: log.energyLevel)
                        )
                    }
                    if log.painLevel > 0 {
                        DetailChip(
                            icon: "bolt.fill",
                            label: "\(log.painLevel)/10",
                            color: .orange
                        )
                    }
                }

                if let symptoms = log.symptoms as? Set<Symptom>,
                   !symptoms.isEmpty
                {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(Self.sortedSymptoms(symptoms), id: \.id) { symptom in
                                let category = Self.symptomCategory(from: symptom.category)
                                Text(Self.symptomName(symptom))
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(
                                        Self.categoryColor(category)
                                            .opacity(0.12)
                                    )
                                    .foregroundColor(
                                        Self.categoryColor(category)
                                    )
                                    .cornerRadius(10)
                            }
                        }
                    }
                }

                if let notes = log.notes, !notes.isEmpty {
                    HStack(alignment: .top, spacing: 6) {
                        Image(systemName: "note.text")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding(.top, 4)
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.plus")
                        .foregroundColor(.themeAccent)
                    Text("Tap to log your cycle, symptoms, or mood.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
                .shadow(
                    color: Color.black.opacity(0.04),
                    radius: 8, x: 0, y: 2
                )
        )
        .padding(.horizontal)
        .frame(minHeight: 140, alignment: .top)
    }

    static func flowDescription(for flowLevel: Int16) -> String {
        FlowLevel(rawValue: flowLevel)?.description ?? "Flow"
    }

    static func moodIcon(for mood: Int16) -> String {
        Mood(rawValue: mood)?.icon ?? "face.smiling"
    }

    static func moodDescription(for mood: Int16) -> String {
        Mood(rawValue: mood)?.description ?? ""
    }

    static func energyLevel(for rawValue: Int16) -> EnergyLevel {
        EnergyLevel(rawValue: rawValue) ?? .medium
    }

    static func symptomCategory(from rawValue: String?) -> SymptomCategory? {
        SymptomCategory(rawValue: rawValue ?? "Physical")
    }

    static func symptomName(_ symptom: Symptom) -> String {
        symptom.name ?? ""
    }

    static func sortedSymptoms(_ symptoms: Set<Symptom>) -> [Symptom] {
        Array(symptoms).sorted(by: {
            symptomName($0) < symptomName($1)
        })
    }

    static func categoryColor(_ category: SymptomCategory?) -> Color {
        switch category {
        case .physical: .themePeriod
        case .mood: .themeFertile
        case .digestion: .orange
        default: .secondary
        }
    }

    static func energyColor(for level: EnergyLevel) -> Color {
        switch level {
        case .low: .orange
        case .high: .green
        case .medium: .themeAccent
        }
    }
}

private struct DetailChip: View {
    let icon: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11))
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.12))
        .foregroundColor(color)
        .clipShape(Capsule())
    }
}

private struct EnergyHighlight: View {
    let level: EnergyLevel

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: level.icon)
                .font(.system(size: 11))
            Text(level.description)
                .font(.caption2)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(backgroundColor.opacity(0.12))
        .foregroundColor(backgroundColor)
        .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        CalendarDayDetailView.energyColor(for: level)
    }
}
