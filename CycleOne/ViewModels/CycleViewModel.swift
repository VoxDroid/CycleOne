//
//  CycleViewModel.swift
//  CycleOne
//

import Combine
import CoreData
import Foundation
import OSLog
import SwiftUI

final class CycleViewModel: ObservableObject {
    @Published var selectedDate: Date = .init().startOfDay
    @Published var currentMonth: Date = .init().startOfDay
    @Published var daysUntilPeriod: Int?
    @Published var daysUntilOvulation: Int?
    @Published var isIrregular: Bool = false
    @Published var dayStatuses: [Date: DayStatus] = [:]
    @Published var selectedDayLog: DayLog?

    @AppStorage("enablePredictions") var enablePredictions = true

    private let context: NSManagedObjectContext
    private let engine = CycleEngine()
    private var cancellables = Set<AnyCancellable>()

    init(context: NSManagedObjectContext) {
        self.context = context

        // Refresh when context changes
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: context)
            .sink { [weak self] _ in
                self?.refreshData()
            }
            .store(in: &cancellables)

        refreshData()
    }

    func refreshData() {
        let fetchRequest: NSFetchRequest<Cycle> = Cycle.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Cycle.startDate, ascending: true)]

        do {
            let cycles = try context.fetch(fetchRequest)

            // Stats & Predictions
            if enablePredictions {
                daysUntilPeriod = engine.predictNextPeriodStart(from: cycles).map { Date().startOfDay.days(from: $0) }
                daysUntilOvulation = engine.predictOvulation(from: cycles).map { Date().startOfDay.days(from: $0) }
                isIrregular = engine.isCycleIrregular(cycles: cycles)
            } else {
                daysUntilPeriod = nil
                daysUntilOvulation = nil
                isIrregular = false
            }

            // Update day statuses for current month and neighbors
            updateDayStatuses(cycles: cycles)

            // Refresh selected day log
            fetchSelectedDayLog()
        } catch {
            Logger.storage.error("Fetch failed: \(error.localizedDescription)")
        }
    }

    private func updateDayStatuses(cycles: [Cycle]) {
        var statuses: [Date: DayStatus] = [:]

        // 1. Logged days
        let logRequest: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        if let logs = try? context.fetch(logRequest) {
            for log in logs {
                if let date = log.date {
                    var status = DayStatus()
                    status.flow = FlowLevel(rawValue: log.flowLevel) ?? .none
                    status.hasLogs = true
                    statuses[date.startOfDay] = status
                }
            }
        }

        // 2. Predictions
        if enablePredictions, !cycles.isEmpty {
            let predictedStart = engine.predictNextPeriodStart(from: cycles)
            if let start = predictedStart {
                for offset in 0 ..< 5 { // Assume 5 days period for prediction
                    let date = start.adding(days: offset).startOfDay
                    var status = statuses[date] ?? DayStatus()
                    status.isPredicted = true
                    statuses[date] = status
                }
            }

            let ovulation = engine.predictOvulation(from: cycles)
            if let ovDate = ovulation {
                var status = statuses[ovDate.startOfDay] ?? DayStatus()
                status.isOvulation = true
                statuses[ovDate.startOfDay] = status

                // Fertile window: -5 to +1 days from ovulation
                for offset in -5 ... 1 {
                    if let date = Calendar.current.date(byAdding: .day, value: offset, to: ovDate)?.startOfDay {
                        var fStatus = statuses[date] ?? DayStatus()
                        fStatus.isFertile = true
                        statuses[date] = fStatus
                    }
                }
            }
        }

        self.dayStatuses = statuses
    }

    private func fetchSelectedDayLog() {
        let request: NSFetchRequest<DayLog> = DayLog.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@", selectedDate as NSDate)
        request.fetchLimit = 1

        selectedDayLog = (try? context.fetch(request))?.first
    }

    func selectDate(_ date: Date) {
        selectedDate = date.startOfDay
        fetchSelectedDayLog()
    }

    func nextMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    func previousMonth() {
        if let newMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    func goTo(date: Date) {
        currentMonth = date.startOfMonth
        refreshData()
    }
}

extension Date {
    var startOfMonth: Date {
        Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self)) ?? self
    }
}
