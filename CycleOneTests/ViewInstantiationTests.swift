import CoreData
@testable import CycleOne
import SwiftUI
import XCTest

final class ViewInstantiationTests: XCTestCase {
    func testOnboardingTipView_body_builds() {
        let view = OnboardingTipView(onDismiss: {})
        _ = view.body
    }

    func testEmptyStateView_body_builds() {
        let view = EmptyStateView(icon: "xmark.circle", title: "No Data", message: "Please add data")
        _ = view.body
    }

    func testPillBadge_body_builds() {
        let view = PillBadge(text: "New", color: .themeAccent)
        _ = view.body
    }

    func testPhaseIndicator_body_builds() {
        let view = PhaseIndicator(phase: "Fertile", color: .green)
        _ = view.body
    }

    func testCycleComparisonView_body_builds_withCycles() {
        let context = TestPersistenceController.empty().container.viewContext
        let start = Date().startOfDay

        let c1 = Cycle(context: context)
        c1.startDate = start
        c1.cycleLength = 28
        c1.periodLength = 5

        let c2 = Cycle(context: context)
        c2.startDate = Calendar.current.date(byAdding: .day, value: -30, to: start)
        c2.cycleLength = 30
        c2.periodLength = 5

        let view = CycleComparisonView(cycles: [c1, c2])
        _ = view.body
    }
}
