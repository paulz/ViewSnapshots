import ExampleApp
@testable import ViewSnapshotTesting
import UniformTypeIdentifiers
import XCTest

class RenderViewTest: XCTestCase {
    func getPng() throws -> Data {
        try inWindowView(RainbowGlowView_Previews.previews) {
            $0.renderHierarchyAsPNG()
        }
    }
    func testRenderingProduceSamePngRepeatedly() throws {
        let viewData1 = try getPng()
        let viewData2 = try getPng()
        XCTContext.runActivity(named: "compare png data from the same view") {
            $0.add(viewData1.pngAttachment())
            $0.add(viewData2.pngAttachment())
            XCTAssertEqual(viewData1, viewData2)
        }
    }
}
