//
//  CycleEnums.swift
//  CycleOne
//

import Foundation
import SwiftUI

enum FlowLevel: Int16, CaseIterable {
    case none = 0
    case light = 1
    case medium = 2
    case heavy = 3

    var description: String {
        switch self {
        case .none: "None"
        case .light: "Light"
        case .medium: "Medium"
        case .heavy: "Heavy"
        }
    }

    var icon: String {
        switch self {
        case .none: "drop"
        case .light: "drop"
        case .medium: "drop.fill"
        case .heavy: "drop.halffull"
        }
    }
}

enum Mood: Int16, CaseIterable {
    case happy = 0
    case neutral = 1
    case sad = 2
    case anxious = 3
    case angry = 4

    var icon: String {
        switch self {
        case .happy: "face.smiling"
        case .neutral: "face.dashed"
        case .sad: "cloud.drizzle.fill"
        case .anxious: "face.smiling.inverse"
        case .angry: "flame.fill"
        }
    }

    var description: String {
        switch self {
        case .happy: "Happy"
        case .neutral: "Neutral"
        case .sad: "Sad"
        case .anxious: "Anxious"
        case .angry: "Angry"
        }
    }
}

enum EnergyLevel: Int16, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2

    var icon: String {
        switch self {
        case .low: "battery.25"
        case .medium: "battery.50"
        case .high: "battery.100"
        }
    }

    var description: String {
        switch self {
        case .low: "Low"
        case .medium: "Normal"
        case .high: "High"
        }
    }
}

enum SymptomCategory: String, CaseIterable {
    case physical = "Physical"
    case mood = "Mood & Mental"
    case digestion = "Digestion"
    case other = "Other"

    var icon: String {
        switch self {
        case .physical: "figure.walk"
        case .mood: "brain.head.profile"
        case .digestion: "leaf.fill"
        case .other: "ellipsis.circle"
        }
    }

    var color: Color {
        switch self {
        case .physical: .themePeriod
        case .mood: .themeFertile
        case .digestion: .orange
        case .other: .secondary
        }
    }
}

struct SymptomType: Identifiable, Hashable {
    let id: String
    let name: String
    let category: SymptomCategory

    static let defaults: [SymptomType] = [
        // Physical
        SymptomType(id: "cramps", name: "Cramps", category: .physical),
        SymptomType(id: "bloating", name: "Bloating", category: .physical),
        SymptomType(id: "headache", name: "Headache", category: .physical),
        SymptomType(id: "acne", name: "Acne", category: .physical),
        SymptomType(id: "breast_tenderness", name: "Breast Tenderness", category: .physical),
        SymptomType(id: "back_pain", name: "Back Pain", category: .physical),
        SymptomType(id: "dizziness", name: "Dizziness", category: .physical),
        // Digestion
        SymptomType(id: "nausea", name: "Nausea", category: .digestion),
        // Mood & Mental
        SymptomType(id: "mood_swings", name: "Mood Swings", category: .mood),
        SymptomType(id: "irritability", name: "Irritability", category: .mood),
        SymptomType(id: "fatigue", name: "Fatigue", category: .mood),
        // Other
        SymptomType(id: "cravings", name: "Cravings", category: .other),
        SymptomType(id: "insomnia", name: "Insomnia", category: .other),
    ]
}
