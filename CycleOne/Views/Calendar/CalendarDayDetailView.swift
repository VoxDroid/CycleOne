//
//  CalendarDayDetailView.swift
//  CycleOne
//

import SwiftUI

struct CalendarDayDetailView: View {
    let date: Date
    let log: DayLog?
    let onLog: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(date.formatted(date: .complete, time: .omitted))
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if let log, log.flowLevel > 0 {
                        Text(FlowLevel(rawValue: log.flowLevel)?.description ?? "Flow")
                            .font(.headline)
                            .foregroundColor(.themePeriod)
                    } else {
                        Text("No Period Logged")
                            .font(.headline)
                    }
                }

                Spacer()

                NavigationLink(value: date) {
                    HStack(spacing: 4) {
                        Image(systemName: log == nil ? "plus.circle.fill" : "pencil.circle.fill")
                        Text(log == nil ? "Log Day" : "Edit Log")
                    }
                    .font(.footnote)
                    .fontWeight(.bold)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.themeAccent)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                }
            }

            if let log {
                HStack(spacing: 12) {
                    if log.mood > 0 {
                        DetailItem(
                            icon: Mood(rawValue: log.mood)?.icon ?? "face.smiling",
                            label: "Mood",
                            value: Mood(rawValue: log.mood)?.description ?? ""
                        )
                    }
                    if log.energyLevel > 0 {
                        EnergyHighlight(level: EnergyLevel(rawValue: log.energyLevel) ?? .medium)
                    }
                    if log.painLevel > 0 {
                        DetailItem(icon: "exclamationmark.circle", label: "Pain", value: "\(log.painLevel)/10")
                    }
                }

                if let symptoms = log.symptoms as? Set<Symptom>, !symptoms.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(symptoms).sorted(by: { ($0.name ?? "") < ($1.name ?? "") }),
                                    id: \.id)
                            { symptom in
                                Text(symptom.name ?? "")
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.secondary.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }

                HStack(alignment: .top, spacing: 4) {
                    Image(systemName: "note.text")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    if let notes = log.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    } else {
                        Text("Empty")
                            .font(.caption)
                            .italic()
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                }
                .padding(.top, 4)
            } else {
                HStack(spacing: 6) {
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
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .padding(.horizontal)
        .frame(minHeight: 140, alignment: .top)
    }
}

private struct EnergyHighlight: View {
    let level: EnergyLevel

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: level.icon)
                .font(.system(size: 12))
            Text(level.description)
                .font(.caption2)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(backgroundColor.opacity(0.15))
        .foregroundColor(backgroundColor)
        .clipShape(Capsule())
    }

    private var backgroundColor: Color {
        switch level {
        case .low: .orange
        case .medium: .themeAccent
        case .high: .green
        }
    }
}

private struct DetailItem: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.themeAccent)
            Text(value)
                .font(.caption2)
                .fontWeight(.medium)
        }
    }
}
