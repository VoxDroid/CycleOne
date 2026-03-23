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

            if !lastDecoratedDates.contains(dateComponents) {
                lastDecoratedDates.append(dateComponents)
            }

            let status = parent.viewModel.dayStatuses[date.startOfDay] ?? DayStatus()

            // Multiple decorations if needed
            if status.flow != .none {
                return .customView {
                    let view = UIView()
                    view.backgroundColor = UIColor.systemPink // Standard period color
                    view.layer.cornerRadius = 6 // Smaller circle for decoration area
                    view.alpha = 0.6
                    view.frame = CGRect(x: 0, y: 0, width: 12, height: 12)
                    return view
                }
            } else if status.isPredicted {
                return .default(color: .systemGray, size: .small)
            } else if status.isOvulation {
                return .default(color: .systemTeal, size: .medium)
            } else if status.isFertile {
                return .default(color: UIColor.systemTeal.withAlphaComponent(0.3), size: .small)
            } else if status.hasLogs {
                return .default(color: .secondaryLabel, size: .small)
            }

            return nil
        }
    }
}
