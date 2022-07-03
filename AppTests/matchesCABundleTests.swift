import XCTest
@testable import ViewSnapshotTesting
@testable import ExampleApp
import SwiftUI
import AEXML

class matchesCABundleTests: XCTestCase {
    func testSnapshots() {
        matchesCABundle(ComplexView_Previews.self)
        
        SnapshotsConfiguration.withColorAccuracy(0) {
            matchesCABundle(TelevisionView_Previews.self)
            matchesCABundle(ToggleView_Previews.self)
            matchesCABundle(RainbowGlowView_Previews.self)
            matchesCABundle(ContentView_Previews.self)
            matchesCABundle(PopularityBadge_Previews.self)
            matchesCABundle(SettingsForm_Previews.self)
            matchesCABundle(LayeringShadowsView_Previews.self)
        }
    }
}
