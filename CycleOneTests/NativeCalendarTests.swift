import CoreData
@testable import CycleOne
import SwiftUI
import UIKit
import XCTest

final class NativeCalendarTests: XCTestCase {
    func testNativeCalendarView_builds_and_updates() throws {
        let context = TestPersistenceController.empty().container.viewContext
        let viewModel = CycleViewModel(context: context)

        // Initial host to exercise makeUIView
        host(NativeCalendarView(viewModel: viewModel))

        // Modify selected date to exercise updateUIView path
        let newDate = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: 3, to: Date().startOfDay))
        viewModel.selectDate(newDate)

        // Host again to trigger update paths
        host(NativeCalendarView(viewModel: viewModel))
    }

    @MainActor
    func testCoordinator_dateSelection_handlesNilAndValidComponents() throws {
        let context = TestPersistenceController.empty().container.viewContext
        let viewModel = CycleViewModel(context: context)
        let nativeView = NativeCalendarView(viewModel: viewModel)
        let coordinator = nativeView.makeCoordinator()

        let selection = UICalendarSelectionSingleDate(delegate: coordinator)
        coordinator.dateSelection(selection, didSelectDate: nil)

        let targetDate = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: 2, to: Date().startOfDay))
        let components = Calendar.current.dateComponents([.year, .month, .day], from: targetDate)
        coordinator.dateSelection(selection, didSelectDate: components)

        XCTAssertEqual(viewModel.selectedDate, targetDate.startOfDay)
    }

    @MainActor
    func testCoordinator_decoration_handlesInvalidAndHasLogsPaths() {
        let context = TestPersistenceController.empty().container.viewContext
        let viewModel = CycleViewModel(context: context)
        let nativeView = NativeCalendarView(viewModel: viewModel)
        let coordinator = nativeView.makeCoordinator()

        let calendarView = UICalendarView()
        XCTAssertNil(coordinator.calendarView(calendarView, decorationFor: DateComponents()))

        let logDate = Date().startOfDay
        viewModel.dayStatuses[logDate] = DayStatus(
            flow: .none,
            isPredicted: false,
            isOvulation: false,
            isFertile: false,
            hasLogs: true
        )

        let components = Calendar.current.dateComponents([.year, .month, .day], from: logDate)
        XCTAssertNotNil(coordinator.calendarView(calendarView, decorationFor: components))
    }
}
