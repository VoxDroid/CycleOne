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
        // Force view load and layout so conditional SwiftUI branches are materialized.
        let hostView = vc.view
        hostView?.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        hostView?.setNeedsLayout()
        hostView?.layoutIfNeeded()
    }

    if Thread.isMainThread {
        instantiate()
    } else {
        DispatchQueue.main.sync {
            instantiate()
        }
    }
}
