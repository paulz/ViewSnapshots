import XCTest
@testable import ExampleApp
import ViewSnapshotTesting

class AppTests: XCTestCase {
    func testPreviews() throws {
        verifySnapshot(ContentView_Previews.self)
        verifySnapshot(PopularityBadge_Previews.self)
        verifySnapshot(SettingsForm_Previews.self)
        verifySnapshot(LayeringShadowsView_Previews.self)
        verifySnapshot(RainbowGlowView_Previews.self)
        verifySnapshot(ToggleView_Previews.self)
    }
}
