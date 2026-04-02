//
//  Logger+Extensions.swift
//  CycleOne
//

import Foundation
import OSLog

extension Logger {
    private static let subsystem = "com.drei.CycleOne"

    static let storage = Logger(subsystem: subsystem, category: "storage")
    static let viewCycle = Logger(subsystem: subsystem, category: "viewCycle")
    static let notifications = Logger(subsystem: subsystem, category: "notifications")
}
