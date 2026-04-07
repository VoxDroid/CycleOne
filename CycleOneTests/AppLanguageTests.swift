@testable import CycleOne
import Foundation
import XCTest

final class AppLanguageTests: XCTestCase {
    private let defaults = UserDefaults.standard

    func testFromStoredValue_defaultsToSystemForUnknown() {
        XCTAssertEqual(AppLanguage.fromStoredValue(nil), .system)
        XCTAssertEqual(AppLanguage.fromStoredValue("unknown"), .system)
    }

    func testCurrentSelection_readsStoredValue() {
        let previous = defaults.string(forKey: AppLanguage.storageKey)
        defer {
            if let previous {
                defaults.set(previous, forKey: AppLanguage.storageKey)
            } else {
                defaults.removeObject(forKey: AppLanguage.storageKey)
            }
        }

        defaults.set(AppLanguage.japanese.rawValue, forKey: AppLanguage.storageKey)
        XCTAssertEqual(AppLanguage.currentSelection(), .japanese)
    }

    func testLocaleMapping_forSupportedLanguages() {
        XCTAssertEqual(AppLanguage.english.locale.identifier, "en")
        XCTAssertEqual(AppLanguage.filipino.locale.identifier, "fil")
        XCTAssertEqual(AppLanguage.japanese.locale.identifier, "ja")
        XCTAssertEqual(AppLanguage.korean.locale.identifier, "ko")
    }

    func testEnglishDisplayNameMapping_forPickerLabels() {
        XCTAssertEqual(AppLanguage.system.englishDisplayName, "System")
        XCTAssertEqual(AppLanguage.english.englishDisplayName, "English")
        XCTAssertEqual(AppLanguage.filipino.englishDisplayName, "Filipino")
        XCTAssertEqual(AppLanguage.japanese.englishDisplayName, "Japanese")
        XCTAssertEqual(AppLanguage.korean.englishDisplayName, "Korean")
    }

    func testLocalizedString_usesLanguageSpecificBundle() {
        XCTAssertEqual(
            AppLanguage.english.localizedString("tab.settings", defaultValue: "Settings"),
            "Settings"
        )
        XCTAssertEqual(
            AppLanguage.filipino.localizedString("tab.settings", defaultValue: "Settings"),
            "Mga Setting"
        )
        XCTAssertEqual(
            AppLanguage.japanese.localizedString("tab.settings", defaultValue: "Settings"),
            "設定"
        )
        XCTAssertEqual(
            AppLanguage.korean.localizedString("tab.settings", defaultValue: "Settings"),
            "설정"
        )
    }

    func testLocalizedResourceURL_existsForPrivacyPolicy() {
        XCTAssertNotNil(
            AppLanguage.english.localizedResourceURL(
                forResource: "PrivacyPolicy",
                withExtension: "html"
            )
        )
        XCTAssertNotNil(
            AppLanguage.filipino.localizedResourceURL(
                forResource: "PrivacyPolicy",
                withExtension: "html"
            )
        )
        XCTAssertNotNil(
            AppLanguage.japanese.localizedResourceURL(
                forResource: "PrivacyPolicy",
                withExtension: "html"
            )
        )
        XCTAssertNotNil(
            AppLanguage.korean.localizedResourceURL(
                forResource: "PrivacyPolicy",
                withExtension: "html"
            )
        )
    }
}
