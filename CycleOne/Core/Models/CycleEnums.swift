//
//  CycleEnums.swift
//  CycleOne
//

import Foundation

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
        case .sad: "face.frowning"
        case .anxious: "face.smiling.inverse" // placeholder
        case .angry: "face.smiling.inverse" // placeholder
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

enum SymptomCategory: String, CaseIterable {
    case physical = "Physical"
    case mood = "Mood & Mental"
    case digestion = "Digestion"
    case other = "Other"
}

struct SymptomType: Identifiable, Hashable {
    let id: String
    let name: String
    let category: SymptomCategory

    static let defaults: [SymptomType] = [
        SymptomType(id: "cramps", name: "Cramps", category: .physical),
        SymptomType(id: "bloating", name: "Bloating", category: .physical),
        SymptomType(id: "headache", name: "Headache", category: .physical),
        SymptomType(id: "acne", name: "Acne", category: .physical),
        SymptomType(id: "breast_tenderness", name: "Breast Tenderness", category: .physical),
        SymptomType(id: "nausea", name: "Nausea", category: .digestion),
        SymptomType(id: "cravings", name: "Cravings", category: .other),
        SymptomType(id: "insomnia", name: "Insomnia", category: .other),
    ]
}
