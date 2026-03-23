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
}
