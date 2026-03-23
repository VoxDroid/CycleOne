//
//  NativeCalendarView.swift
//  CycleOne
//

import SwiftUI
import UIKit

struct NativeCalendarView: UIViewRepresentable {
    @ObservedObject var viewModel: CycleViewModel

    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        calendarView.calendar = .current
        calendarView.locale = .current
        calendarView.fontDesign = .rounded

        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        calendarView.selectionBehavior = selection
        calendarView.delegate = context.coordinator

        // Match selection to viewModel
        let components = Calendar.current.dateComponents([.year, .month, .day], from: viewModel.selectedDate)
        selection.setSelected(components, animated: false)

        return calendarView
    }

    func updateUIView(_ uiView: UICalendarView, context: Context) {
        // Update selection if viewModel changes
        if let selection = uiView.selectionBehavior as? UICalendarSelectionSingleDate {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: viewModel.selectedDate)
            if selection.selectedDate != components {
                selection.setSelected(components, animated: true)
            }
        }

        // Reload decorations
        uiView.reloadDecorations(forDateComponents: context.coordinator.lastDecoratedDates, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: NativeCalendarView
        var lastDecoratedDates: [DateComponents] = []

        init(_ parent: NativeCalendarView) {
            self.parent = parent
        }

        // MARK: - UICalendarSelectionSingleDateDelegate

        func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
            guard let dateComponents, let date = Calendar.current.date(from: dateComponents) else { return }
            parent.viewModel.selectDate(date)
        }

        // MARK: - UICalendarViewDelegate

        func calendarView(_ calendarView: UICalendarView,
                          decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration?
        {
            guard let date = Calendar.current.date(from: dateComponents) else { return nil }
            let status = parent.viewModel.dayStatuses[date.startOfDay] ?? DayStatus()

            lastDecoratedDates.append(dateComponents)

            if status.flow != .none {
                return .default(color: .systemPink, size: .medium)
            } else if status.isPredicted {
                return .default(color: .systemPink.withAlphaComponent(0.4), size: .small)
            } else if status.isOvulation {
                return .default(color: .systemTeal, size: .medium)
            } else if status.isFertile {
                return .default(color: .systemTeal.withAlphaComponent(0.4), size: .small)
            } else if status.hasLogs {
                return .default(color: .secondaryLabel, size: .small)
            }

            return nil
        }
    }
}
