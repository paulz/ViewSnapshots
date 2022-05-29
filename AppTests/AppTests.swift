import XCTest
@testable import ExampleApp
import ViewSnapshotTesting

class AppTests: XCTestCase {
    func testPreviews() throws {
        verifySnapshot(ContentView_Previews.self)
        verifySnapshot(PopularityBadge_Previews.self)
    }
}
