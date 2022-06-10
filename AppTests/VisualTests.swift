import XCTest
@testable import ExampleApp
@testable import ViewSnapshotTesting
import SwiftUI

class VisualTests: XCTestCase {
    override func setUp() {
        super.setUp()
        VTKSetReferenceImagesDirectory("\(type(of: self))")
    }
    func testPreviews() throws {
        verifySnapshot(ContentView_Previews.self)
        verifySnapshot(PopularityBadge_Previews.self)
        verifySnapshot(SettingsForm_Previews.self)
    }
    
    func testFailures() {
        let options = XCTExpectedFailure.Options()
        var failedTimes = 0
        options.issueMatcher = {
            failedTimes += 1
            return $0.type == .assertionFailure &&
            $0.compactDescription == "Given view is not similar to the reference image."
        }
        
        XCTExpectFailure("Fails to match even with recorded", options: options) {
            verifySnapshot(LayeringShadowsView_Previews.self)
            verifySnapshot(RainbowGlowView_Previews.self)
            verifySnapshot(ToggleView_Previews.self)
        }
        XCTAssertEqual(failedTimes, 3, "all above have the same issue")
    }
    
    public func verifySnapshot<P>(_ preview: P.Type = P.self, _ name: String? = nil,
                                  file: StaticString = #file, line: UInt = #line) where P: PreviewProvider {
        var name = name ?? "\(P.self)"
        let commonPreviewSuffix = "_Previews"
        if name.hasSuffix(commonPreviewSuffix) {
            name.removeLast(commonPreviewSuffix.count)
        }
        
        try! inWindowView(preview.previews) { view in
            VTKAssertView(view, name: name, file: file.description, line: line)
        }
    }
}
