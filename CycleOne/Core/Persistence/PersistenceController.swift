//
//  PersistenceController.swift
//  CycleOne
//
//  Created by Antigravity on 3/23/26.
//

import CoreData

struct PersistenceController {
    static let model: NSManagedObjectModel = {
        let bundle = Bundle(for: CycleManager.self)
        guard let url = bundle.url(forResource: "CycleOne", withExtension: "momd") else {
            fatalError("Failed to find CycleOne.momd in bundle \(bundle)")
        }
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load NSManagedObjectModel from \(url)")
        }
        return model
    }()

    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "CycleOne", managedObjectModel: Self.model)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        let container = self.container
        container.loadPersistentStores { description, error in
            if let error = error as NSError? {
                // If migration fails, delete and retry (development only)
                // 134110: NSMigrationMissingSourceModelError
                // 134140: NSMigrationMissingMappingModelError
                if error.code == 134_110 || error.code == 134_140 {
                    if let url = description.url {
                        try? FileManager.default.removeItem(at: url)
                        container.loadPersistentStores { _, retryError in
                            if let retryError = retryError as NSError? {
                                fatalError("Failed to load store after reset: \(retryError)")
                            }
                        }
                    }
                } else {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func save() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
