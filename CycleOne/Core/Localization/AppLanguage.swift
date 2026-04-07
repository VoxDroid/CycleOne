//
//  AppLanguage.swift
//  CycleOne
//

import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english = "en"
    case filipino = "fil"
    case japanese = "ja"
    case chineseSimplified = "zh-Hans"
    case chineseTraditional = "zh-Hant"
    case korean = "ko"

    static let storageKey = "selected_app_language"

    var id: String {
        rawValue
    }

    var locale: Locale {
        switch self {
        case .system:
            .autoupdatingCurrent
        case .english:
            Locale(identifier: "en")
        case .filipino:
            Locale(identifier: "fil")
        case .japanese:
            Locale(identifier: "ja")
        case .chineseSimplified:
            Locale(identifier: "zh-Hans")
        case .chineseTraditional:
            Locale(identifier: "zh-Hant")
        case .korean:
            Locale(identifier: "ko")
        }
    }

    var displayNameKey: LocalizedStringKey {
        switch self {
        case .system:
            "settings.language.system"
        case .english:
            "settings.language.english"
        case .filipino:
            "settings.language.filipino"
        case .japanese:
            "settings.language.japanese"
        case .chineseSimplified:
            "settings.language.simplified_chinese"
        case .chineseTraditional:
            "settings.language.traditional_chinese"
        case .korean:
            "settings.language.korean"
        }
    }

    var englishDisplayName: String {
        switch self {
        case .system:
            "System"
        case .english:
            "English"
        case .filipino:
            "Filipino"
        case .japanese:
            "Japanese"
        case .chineseSimplified:
            "Simplified Chinese"
        case .chineseTraditional:
            "Traditional Chinese"
        case .korean:
            "Korean"
        }
    }

    static func fromStoredValue(_ rawValue: String?) -> AppLanguage {
        AppLanguage(rawValue: rawValue ?? "") ?? .system
    }

    static func currentSelection(
        userDefaults: UserDefaults = .standard
    ) -> AppLanguage {
        fromStoredValue(
            userDefaults.string(forKey: storageKey)
        )
    }

    var resourceLanguageCode: String? {
        switch self {
        case .system:
            nil
        case .english:
            "en"
        case .filipino:
            "fil"
        case .japanese:
            "ja"
        case .chineseSimplified:
            "zh-Hans"
        case .chineseTraditional:
            "zh-Hant"
        case .korean:
            "ko"
        }
    }

    var localizedBundle: Bundle {
        guard
            let languageCode = resourceLanguageCode,
            let bundle = Bundle.localizedBundle(for: languageCode)
        else {
            return .main
        }
        return bundle
    }

    func localizedResourceURL(
        forResource name: String,
        withExtension ext: String
    ) -> URL? {
        localizedBundle.url(forResource: name, withExtension: ext)
    }

    func localizedString(
        _ key: String,
        defaultValue: String
    ) -> String {
        let value = localizedBundle.localizedString(
            forKey: key,
            value: defaultValue,
            table: nil
        )
        return value == key ? defaultValue : value
    }

    static func localizedString(
        _ key: String,
        defaultValue: String
    ) -> String {
        currentSelection().localizedString(
            key,
            defaultValue: defaultValue
        )
    }
}

private extension Bundle {
    static func localizedBundle(for languageCode: String) -> Bundle? {
        if
            let directPath = Bundle.main.path(
                forResource: languageCode,
                ofType: "lproj"
            ),
            let bundle = Bundle(path: directPath)
        {
            return bundle
        }

        if
            let groupedPath = Bundle.main.path(
                forResource: languageCode,
                ofType: "lproj",
                inDirectory: "LocalizationResources"
            ),
            let bundle = Bundle(path: groupedPath)
        {
            return bundle
        }

        return nil
    }
}
