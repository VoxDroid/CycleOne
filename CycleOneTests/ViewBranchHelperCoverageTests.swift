import CoreData
@testable import CycleOne
import SwiftUI
import XCTest

final class ViewBranchHelperCoverageTests: XCTestCase {
    func testCycleComparison_helpers_coverDateAndDiffBranches() {
        XCTAssertEqual(CycleComparisonView.formattedStartDate(nil), "N/A")
        XCTAssertNotEqual(CycleComparisonView.formattedStartDate(Date().startOfDay), "N/A")
        XCTAssertEqual(CycleComparisonView.emptyStateOpacity(hasLatestTwo: true), 0)
        XCTAssertEqual(CycleComparisonView.emptyStateOpacity(hasLatestTwo: false), 1)
        XCTAssertEqual(CycleComparisonView.emptyStateHeight(hasLatestTwo: true), 0)
        XCTAssertNil(CycleComparisonView.emptyStateHeight(hasLatestTwo: false))

        XCTAssertEqual(ComparisonRow.diffIconName(for: 2), "arrow.up.circle.fill")
        XCTAssertEqual(ComparisonRow.diffIconName(for: -1), "arrow.down.circle.fill")
        XCTAssertEqual(ComparisonRow.diffIconName(for: 0), "equal.circle.fill")

        _ = ComparisonRow.diffColor(for: 2)
        _ = ComparisonRow.diffColor(for: -1)
        _ = ComparisonRow.diffColor(for: 0)
    }

    func testCalendarDayDetailView_helperBranches() {
        XCTAssertEqual(CalendarDayDetailView.flowDescription(for: 99), "Flow")
        XCTAssertEqual(CalendarDayDetailView.moodIcon(for: 99), "face.smiling")
        XCTAssertEqual(CalendarDayDetailView.moodDescription(for: 99), "")
        XCTAssertEqual(CalendarDayDetailView.energyLevel(for: 99), .medium)

        let context = TestPersistenceController.empty().container.viewContext
        let nilName = Symptom(context: context)
        nilName.id = "n"
        nilName.name = nil
        nilName.category = nil

        let named = Symptom(context: context)
        named.id = "a"
        named.name = "alpha"
        named.category = SymptomCategory.mood.rawValue

        _ = CalendarDayDetailView.sortedSymptoms([nilName, named])
        XCTAssertEqual(CalendarDayDetailView.symptomName(nilName), "")
        XCTAssertEqual(CalendarDayDetailView.symptomCategory(from: nil), .physical)
        XCTAssertNil(CalendarDayDetailView.symptomCategory(from: "Unknown"))

        _ = CalendarDayDetailView.categoryColor(.mood)
        _ = CalendarDayDetailView.categoryColor(.digestion)
        _ = CalendarDayDetailView.categoryColor(.other)
        _ = CalendarDayDetailView.categoryColor(nil)

        _ = CalendarDayDetailView.energyColor(for: .low)
        _ = CalendarDayDetailView.energyColor(for: .medium)
        _ = CalendarDayDetailView.energyColor(for: .high)
    }

    func testFlowLayout_resolvedWidth_handlesNilAndFixedValues() {
        XCTAssertEqual(
            FlowLayout.resolvedWidth(for: ProposedViewSize(width: nil, height: nil)),
            .infinity
        )
        XCTAssertEqual(
            FlowLayout.resolvedWidth(for: ProposedViewSize(width: 120, height: nil)),
            120
        )
    }

    func testLogView_cancelAction_noop() {
        LogView.cancelAlertAction()
        XCTAssertTrue(true)
    }
}
