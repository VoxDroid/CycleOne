@testable import CycleOne
import XCTest

final class CycleEnumsTests: XCTestCase {
    func testFlowLevelDescriptionsAndIcons() {
        let expected: [(FlowLevel, String, String)] = [
            (.none, "None", "drop"),
            (.light, "Light", "drop"),
            (.medium, "Medium", "drop.fill"),
            (.heavy, "Heavy", "drop.halffull"),
        ]

        XCTAssertEqual(FlowLevel.allCases.count, expected.count)
        for (flow, description, icon) in expected {
            XCTAssertEqual(flow.description, description)
            XCTAssertEqual(flow.icon, icon)
        }
    }

    func testMoodDescriptionsAndIcons() {
        let expected: [(Mood, String, String)] = [
            (.happy, "Happy", "face.smiling"),
            (.neutral, "Neutral", "face.dashed"),
            (.sad, "Sad", "cloud.drizzle.fill"),
            (.anxious, "Anxious", "face.smiling.inverse"),
            (.angry, "Angry", "flame.fill"),
        ]

        XCTAssertEqual(Mood.allCases.count, expected.count)
        for (mood, description, icon) in expected {
            XCTAssertEqual(mood.description, description)
            XCTAssertEqual(mood.icon, icon)
        }
    }

    func testEnergyLevelDescriptionsAndIcons() {
        let expected: [(EnergyLevel, String, String)] = [
            (.low, "Low", "battery.25"),
            (.medium, "Normal", "battery.50"),
            (.high, "High", "battery.100"),
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
}
