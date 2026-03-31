import CoreData
@testable import CycleOne
import SwiftUI
import XCTest

final class ViewBranchTests: XCTestCase {
    func testCycleComparisonView_showsEmptyStateWhenNotEnoughCycles() {
        host(CycleComparisonView(cycles: []))
    }

    func testCycleComparisonView_diffPositiveAndZero() {
        let context = TestPersistenceController.empty().container.viewContext

        let c1 = Cycle(context: context)
        c1.startDate = Date().startOfDay
        c1.cycleLength = 30
        c1.periodLength = 5

        let c2 = Cycle(context: context)
        c2.startDate = Calendar.current.date(byAdding: .day, value: -30, to: Date().startOfDay)
        c2.cycleLength = 28
        c2.periodLength = 4

        // current (30) vs previous (28) -> positive diff
        host(CycleComparisonView(cycles: [c1, c2]), context: context)

        // zero diff case
        let c3 = Cycle(context: context)
        c3.startDate = Date().startOfDay
        c3.cycleLength = 28
        c3.periodLength = 5

        let c4 = Cycle(context: context)
        c4.startDate = Calendar.current.date(byAdding: .day, value: -28, to: Date().startOfDay)
        c4.cycleLength = 28
        c4.periodLength = 5

        host(CycleComparisonView(cycles: [c3, c4]), context: context)
    }

    func testCycleComparisonView_diffNegative() {
        let context = TestPersistenceController.empty().container.viewContext

        let c1 = Cycle(context: context)
        c1.startDate = Date().startOfDay
        c1.cycleLength = 26
        c1.periodLength = 4

        let c2 = Cycle(context: context)
        c2.startDate = Calendar.current.date(byAdding: .day, value: -26, to: Date().startOfDay)
        c2.cycleLength = 30
        c2.periodLength = 6

        // current (26) vs previous (30) -> negative diff
        host(CycleComparisonView(cycles: [c1, c2]), context: context)
    }
}
