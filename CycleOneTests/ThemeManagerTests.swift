//
//  ThemeManagerTests.swift
//  CycleOneTests
//

@testable import CycleOne
import XCTest

final class ThemeManagerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Clear UserDefaults for testing
        UserDefaults.standard.removeObject(forKey: "appTheme")
    }

    func testInitialTheme() {
        let manager = ThemeManager()
        XCTAssertEqual(manager.selectedTheme, .system)
    }

    func testThemePersistence() {
        let manager = ThemeManager()
        manager.selectedTheme = .dark

        // Create a new manager instance and verify it loaded the persisted value
        let newManager = ThemeManager()
        XCTAssertEqual(newManager.selectedTheme, .dark)
    }

    func testThemeRawValuePersistence() {
        let manager = ThemeManager()
        manager.selectedTheme = .light

        let storedValue = UserDefaults.standard.string(forKey: "appTheme")
        XCTAssertEqual(storedValue, AppTheme.light.rawValue)
    }
}
