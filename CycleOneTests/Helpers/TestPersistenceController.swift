//
//  TestPersistenceController.swift
//  CycleOneTests
//
//  Created by Antigravity on 3/23/26.
//

import CoreData
@testable import CycleOne

final class TestPersistenceController {
    static let shared = TestPersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "CycleOne")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func reset() {
        let context = container.viewContext
        let entities = container.managedObjectModel.entities
        for entity in entities {
            guard let name = entity.name else { continue }
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                // Silently fail or log in test helper
            }
        }
    }
}
