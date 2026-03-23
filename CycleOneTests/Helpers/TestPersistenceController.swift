//
//  TestPersistenceController.swift
//  CycleOneTests
//

import CoreData
@testable import CycleOne
import Foundation

enum TestPersistenceController {
    static func empty() -> PersistenceController {
        PersistenceController(inMemory: true)
    }
}
