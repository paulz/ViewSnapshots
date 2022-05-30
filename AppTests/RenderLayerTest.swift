import XCTest
@testable import ExampleApp
@testable import ViewSnapshotTesting

class RenderLayerTest: XCTestCase {
    func testRenderLayerDoesNotIncludeAllShadows() throws {
        let withShadowsUrl = folderUrl().appendingPathComponent("RainbowGlowView.png")
        let layerUrl = folderUrl().appendingPathComponent("RainbowGlowView-layer.png")
        let pngData = try! inWindowView(RainbowGlowView_Previews.previews) {
            $0.renderLayerAsPNG()
        }
        let layerOnlyData = try Data(contentsOf: layerUrl)
        let withShadowsData = try Data(contentsOf: withShadowsUrl)
        XCTAssertNotEqual(withShadowsData, pngData)
        if layerOnlyData != pngData {
            let result = compare(layerOnlyData, pngData)
            XCTAssertLessThanOrEqual(result.maxColorDifference(), 0.015625)
            if result.maxColorDifference() > 0.015625 {
                try pngData.write(to: layerUrl)
            }
        }
    }
}
