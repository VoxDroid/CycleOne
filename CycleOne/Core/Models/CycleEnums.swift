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

    var accessibilityName: String {
        switch self {
        case .none: "none"
        case .light: "light"
        case .medium: "medium"
        case .heavy: "heavy"
        }
    }

    var description: String {
        switch self {
        case .none:
            L10n.string("flow.none", default: "None")
        case .light:
            L10n.string("flow.light", default: "Light")
        case .medium:
            L10n.string("flow.medium", default: "Medium")
        case .heavy:
            L10n.string("flow.heavy", default: "Heavy")
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
        case .happy:
            L10n.string("mood.happy", default: "Happy")
        case .neutral:
            L10n.string("mood.neutral", default: "Neutral")
        case .sad:
            L10n.string("mood.sad", default: "Sad")
        case .anxious:
            L10n.string("mood.anxious", default: "Anxious")
        case .angry:
            L10n.string("mood.angry", default: "Angry")
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
        case .low:
            L10n.string("energy.low", default: "Low")
        case .medium:
            L10n.string("energy.medium", default: "Normal")
        case .high:
            L10n.string("energy.high", default: "High")
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

    var localizedName: String {
        switch self {
        case .physical:
            L10n.string("symptom.category.physical", default: "Physical")
        case .mood:
            L10n.string("symptom.category.mood", default: "Mood & Mental")
        case .digestion:
            L10n.string("symptom.category.digestion", default: "Digestion")
        case .other:
            L10n.string("symptom.category.other", default: "Other")
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

    var localizedName: String {
        SymptomType.localizedName(forID: id, fallbackName: name)
    }

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

    static func localizedName(forID id: String?, fallbackName: String) -> String {
        guard let id else { return fallbackName }

        let defaultName = defaults.first(where: { $0.id == id })?.name ?? fallbackName
        return L10n.string("symptom.\(id)", default: defaultName)
    }

    static func localizedName(forName name: String) -> String {
        guard
            let match = defaults.first(where: {
                $0.name.caseInsensitiveCompare(name) == .orderedSame
            })
        else {
            return name
        }

        return localizedName(forID: match.id, fallbackName: match.name)
    }
}
