@testable import CycleOne
import XCTest

final class CycleEnumsTests: XCTestCase {
    func testFlowLevelDescriptionsAndIcons() {
        let expected: [(FlowLevel, String, String)] = [
            (.none, L10n.string("flow.none", default: "None"), "drop"),
            (.light, L10n.string("flow.light", default: "Light"), "drop"),
            (.medium, L10n.string("flow.medium", default: "Medium"), "drop.fill"),
            (.heavy, L10n.string("flow.heavy", default: "Heavy"), "drop.halffull"),
        ]

        XCTAssertEqual(FlowLevel.allCases.count, expected.count)
        for (flow, description, icon) in expected {
            XCTAssertEqual(flow.description, description)
            XCTAssertEqual(flow.icon, icon)
        }
    }

    func testMoodDescriptionsAndIcons() {
        let expected: [(Mood, String, String)] = [
            (.happy, L10n.string("mood.happy", default: "Happy"), "face.smiling"),
            (.neutral, L10n.string("mood.neutral", default: "Neutral"), "face.dashed"),
            (.sad, L10n.string("mood.sad", default: "Sad"), "cloud.drizzle.fill"),
            (.anxious, L10n.string("mood.anxious", default: "Anxious"), "face.smiling.inverse"),
            (.angry, L10n.string("mood.angry", default: "Angry"), "flame.fill"),
        ]

        XCTAssertEqual(Mood.allCases.count, expected.count)
        for (mood, description, icon) in expected {
            XCTAssertEqual(mood.description, description)
            XCTAssertEqual(mood.icon, icon)
        }
    }

    func testEnergyLevelDescriptionsAndIcons() {
        let expected: [(EnergyLevel, String, String)] = [
            (.low, L10n.string("energy.low", default: "Low"), "battery.25"),
            (.medium, L10n.string("energy.medium", default: "Normal"), "battery.50"),
            (.high, L10n.string("energy.high", default: "High"), "battery.100"),
        ]

        XCTAssertEqual(EnergyLevel.allCases.count, expected.count)
        for (energy, description, icon) in expected {
            XCTAssertEqual(energy.description, description)
            XCTAssertEqual(energy.icon, icon)
        }
    }

    func testSymptomCategoryIconsAndColorAccessors() {
        XCTAssertEqual(SymptomCategory.physical.icon, "figure.walk")
        XCTAssertEqual(SymptomCategory.mood.icon, "brain.head.profile")
        XCTAssertEqual(SymptomCategory.digestion.icon, "leaf.fill")
        XCTAssertEqual(SymptomCategory.other.icon, "ellipsis.circle")

        for category in SymptomCategory.allCases {
            _ = category.color
            XCTAssertFalse(category.icon.isEmpty)
        }
    }

    func testSymptomDefaultsContainExpectedDataShape() {
        let defaults = SymptomType.defaults

        XCTAssertGreaterThanOrEqual(defaults.count, 10)
        XCTAssertEqual(Set(defaults.map(\.id)).count, defaults.count)
        XCTAssertEqual(Set(defaults.map(\.category)), Set(SymptomCategory.allCases))

        XCTAssertTrue(defaults.contains(where: { $0.id == "cramps" && $0.category == .physical }))
        XCTAssertTrue(defaults.contains(where: { $0.id == "nausea" && $0.category == .digestion }))
        XCTAssertTrue(defaults.contains(where: { $0.id == "mood_swings" && $0.category == .mood }))
        XCTAssertTrue(defaults.contains(where: { $0.id == "insomnia" && $0.category == .other }))
    }

    func testSymptomLocalizedName_forNameCoversMatchAndFallback() {
        XCTAssertEqual(
            SymptomType.localizedName(forName: "Cramps"),
            L10n.string("symptom.cramps", default: "Cramps")
        )
        XCTAssertEqual(
            SymptomType.localizedName(forName: "cRaMpS"),
            L10n.string("symptom.cramps", default: "Cramps")
        )
        XCTAssertEqual(
            SymptomType.localizedName(forName: "Unknown Symptom"),
            "Unknown Symptom"
        )
    }
}
