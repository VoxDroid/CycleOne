@testable import CycleOne
import SwiftUI
import UIKit
import XCTest

final class ThemeManagerTests: XCTestCase {
    private var originalTheme: String?
    private var originalAccent: String?

    override func setUp() {
        super.setUp()
        originalTheme = UserDefaults.standard.string(forKey: "selected_app_theme")
        originalAccent = UserDefaults.standard.string(forKey: "selected_accent_theme")
        UserDefaults.standard.removeObject(forKey: "selected_app_theme")
        UserDefaults.standard.removeObject(forKey: "selected_accent_theme")
    }

    override func tearDown() {
        if let originalTheme {
            UserDefaults.standard.set(originalTheme, forKey: "selected_app_theme")
        } else {
            UserDefaults.standard.removeObject(forKey: "selected_app_theme")
        }

        if let originalAccent {
            UserDefaults.standard.set(originalAccent, forKey: "selected_accent_theme")
        } else {
            UserDefaults.standard.removeObject(forKey: "selected_accent_theme")
        }

        super.tearDown()
    }

    func testAppThemeColorSchemeMapping() {
        XCTAssertNil(AppTheme.system.colorScheme)
        XCTAssertEqual(AppTheme.light.colorScheme, .light)
        XCTAssertEqual(AppTheme.dark.colorScheme, .dark)
    }

    func testAccentThemeMetadataIsPopulated() {
        for accent in AccentTheme.allCases {
            XCTAssertFalse(accent.id.isEmpty)
            XCTAssertFalse(accent.icon.isEmpty)
        }
    }

    func testInitUsesPersistedThemeAndAccent() {
        UserDefaults.standard.set(AppTheme.dark.rawValue, forKey: "selected_app_theme")
        UserDefaults.standard.set(AccentTheme.ocean.rawValue, forKey: "selected_accent_theme")

        let manager = ThemeManager()

        XCTAssertEqual(manager.selectedTheme, .dark)
        XCTAssertEqual(manager.selectedAccent, .ocean)
    }

    func testInitFallsBackForInvalidPersistedValues() {
        UserDefaults.standard.set("invalid-theme", forKey: "selected_app_theme")
        UserDefaults.standard.set("invalid-accent", forKey: "selected_accent_theme")

        let manager = ThemeManager()

        XCTAssertEqual(manager.selectedTheme, .system)
        XCTAssertEqual(manager.selectedAccent, .rose)
    }

    func testDidSetPersistsValuesToUserDefaults() {
        let manager = ThemeManager()

        manager.selectedTheme = .light
        manager.selectedAccent = .sunset

        XCTAssertEqual(UserDefaults.standard.string(forKey: "selected_app_theme"), AppTheme.light.rawValue)
        XCTAssertEqual(UserDefaults.standard.string(forKey: "selected_accent_theme"), AccentTheme.sunset.rawValue)
    }

    func testAccentColorTracksSelectedAccent() {
        let manager = ThemeManager()
        manager.selectedAccent = .sage

        let resolved = UIColor(manager.accentColor)
        let expected = UIColor(AccentTheme.sage.accentColor)

        XCTAssertTrue(resolved.isEqual(expected))
    }
}
