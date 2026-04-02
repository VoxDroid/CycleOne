//
//  PersistenceController.swift
//  CycleOne
//
//  Created by Antigravity on 3/23/26.
//

import CoreData

struct PersistenceController {
    enum StoreLoadResult {
        case loaded
        case resetAndRetry(URL)
        case failed(String)
    }

    private nonisolated static func fatalModelHandler(_ message: String) -> NSManagedObjectModel {
        fatalError(message)
    }

    private nonisolated static func fatalFailureHandler(_ message: String) {
        fatalError(message)
    }

    private nonisolated static func defaultRemoveItem(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }

    static func loadModel(
        modelURL: URL? = Bundle(for: CycleManager.self)
            .url(forResource: "CycleOne", withExtension: "momd"),
        missingResourceHandler: (String) -> NSManagedObjectModel = PersistenceController.fatalModelHandler,
        invalidModelHandler: (String) -> NSManagedObjectModel = PersistenceController.fatalModelHandler
    ) -> NSManagedObjectModel {
        guard let url = modelURL else {
            return missingResourceHandler("Failed to find CycleOne.momd in app bundle")
        }
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            return invalidModelHandler("Failed to load NSManagedObjectModel from \(url)")
        }
        return model
    }

    static func storeLoadResult(
        description: NSPersistentStoreDescription,
        error: Error?
    ) -> StoreLoadResult {
        guard let nsError = error as NSError? else {
            return .loaded
        }

        if nsError.code == 134_110 || nsError.code == 134_140 {
            guard let url = description.url else {
                return .loaded
            }
            return .resetAndRetry(url)
        }

        return .failed("Unresolved error \(nsError), \(nsError.userInfo)")
    }

    static let model: NSManagedObjectModel = loadModel()

    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(
        inMemory: Bool = false,
        loadStores: ((NSPersistentContainer, @escaping (NSPersistentStoreDescription, Error?) -> Void) -> Void)? = nil,
        failureHandler: @escaping (String) -> Void = PersistenceController.fatalFailureHandler,
        removeItem: @escaping (URL) -> Void = PersistenceController.defaultRemoveItem
    ) {
        container = NSPersistentContainer(name: "CycleOne", managedObjectModel: Self.model)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        let container = self.container
        let performLoadStores = loadStores ?? { persistentContainer, completion in
            persistentContainer.loadPersistentStores(completionHandler: completion)
        }

        performLoadStores(container) { description, error in
            switch Self.storeLoadResult(description: description, error: error) {
            case .loaded:
                break
            case let .resetAndRetry(url):
                removeItem(url)
                performLoadStores(container) { _, retryError in
                    if let retryError = retryError as NSError? {
                        failureHandler("Failed to load store after reset: \(retryError)")
                    }
                }
            case let .failed(message):
                failureHandler(message)
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func save(
        context overrideContext: NSManagedObjectContext? = nil,
        failureHandler: (String) -> Void = PersistenceController.fatalFailureHandler
    ) {
        let context = overrideContext ?? container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                failureHandler("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
