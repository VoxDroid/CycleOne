@testable import CycleOne
import SwiftUI
import XCTest

final class ViewExtensionsTests: XCTestCase {
    func testCardAndSectionStylesBuild() {
        host(Text("Card").cardStyle())
        host(Text("Header").sectionHeaderStyle())
        host(Text("Premium").premiumCard())
    }

    func testGentlePulseModifierBuilds() {
        host(Text("Pulse").gentlePulse())
    }

    func testFadeSlideModifierBuildsWithDelay() {
        host(Text("Fade").fadeSlideIn(delay: 0.05))
    }
}
