import CoreData
@testable import CycleOne
import SwiftUI
import UIKit

/// Helper to host SwiftUI views in unit tests and inject ThemeManager and optional managedObjectContext
func host(_ view: some View, context: NSManagedObjectContext? = nil) {
    let wrapped = if let ctx = context {
        AnyView(view.environment(\.managedObjectContext, ctx).environmentObject(ThemeManager.shared))
    } else {
        AnyView(view.environmentObject(ThemeManager.shared))
    }

    let instantiate = {
        let vc = UIHostingController(rootView: wrapped)
        // Force view to load on main thread to exercise SwiftUI body
        _ = vc.view
    }

    if Thread.isMainThread {
        instantiate()
    } else {
        DispatchQueue.main.sync {
            instantiate()
        }
    }
}
