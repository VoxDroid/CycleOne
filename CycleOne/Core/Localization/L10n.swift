//
//  L10n.swift
//  CycleOne
//

import Foundation

enum L10n {
    static func string(
        _ key: String,
        default defaultValue: String
    ) -> String {
        AppLanguage.localizedString(key, defaultValue: defaultValue)
    }

    static func format(
        _ key: String,
        default defaultValue: String,
        _ arguments: CVarArg...
    ) -> String {
        let pattern = string(key, default: defaultValue)
        return String(format: pattern, arguments: arguments)
    }
}
