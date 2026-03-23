//
//  CycleOneApp.swift
//  CycleOne
//
//  Created by Drei on 3/23/26.
//

import CoreData
import SwiftUI

@main
struct CycleOneApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
