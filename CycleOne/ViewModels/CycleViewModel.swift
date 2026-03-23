//
//  CycleViewModel.swift
//  CycleOne
//
//  Created by Antigravity on 3/23/26.
//

import Combine
import CoreData
import Foundation

class CycleViewModel: ObservableObject {
    @Published var nextPeriodDate: Date?
    @Published var daysUntilNextPeriod: Int?

    private let context: NSManagedObjectContext
    private let engine = CycleEngine()

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        // Initial calculation would go here
    }
}
