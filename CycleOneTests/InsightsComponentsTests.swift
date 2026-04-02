import CoreData
@testable import CycleOne
import SwiftUI
import XCTest

final class InsightsComponentsTests: XCTestCase {
    func testCycleLengthChart_and_stat_views_build() throws {
        let data: [(date: Date, length: Int)] = try [
            (date: Date().startOfDay, length: 28),
            (date: XCTUnwrap(Calendar.current.date(byAdding: .day, value: -28, to: Date().startOfDay)), length: 30),
        ]

        host(CycleLengthChartView(data: data))
        host(StatCard(icon: "star", title: "Avg", value: "28", unit: "d", color: .themeAccent))
        host(MiniStatCard(title: "Short", value: "24", icon: "arrow.down", color: .green))
    }

    func testMoodDistribution_and_symptom_breakdown_build() {
        host(MoodDistributionView(distribution: ["Happy": 3, "Sad": 1]))

        // SymptomBreakdownView with varied counts to exercise medal branches
        let symptoms: [(String, Int)] = [
            ("Cramps", 5), ("Bloating", 3), ("Headache", 2), ("Nausea", 1), ("Fatigue", 1), ("Other", 0),
        ]
        host(SymptomBreakdownView(symptoms: symptoms))

        // Also test with fewer than 3 items to hit other branches
        host(SymptomBreakdownView(symptoms: [("Cramps", 1), ("Bloating", 1)]))
    }

    func testInsightsComponentHelpers_coverFallbackBranches() {
        XCTAssertEqual(CycleLengthChartView.maxLength(for: []), 35)
        XCTAssertEqual(
            MoodDistributionView.moodBarWidth(
                total: 0,
                value: 3,
                availableWidth: 200
            ),
            0
        )
        XCTAssertEqual(
            MoodDistributionView.moodBarWidth(
                total: 4,
                value: 2,
                availableWidth: 200
            ),
            100
        )

        XCTAssertEqual(SymptomBreakdownView.maxCount(for: []), 1)
        XCTAssertEqual(SymptomBreakdownView.medalIcon(for: 4), "circle.fill")
        _ = SymptomBreakdownView.medalColor(for: 4)
    }
}
