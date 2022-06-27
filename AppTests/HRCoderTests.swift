import HRCoder
import UniformTypeIdentifiers
import XCTest
@testable import ExampleApp
@testable import ViewSnapshotTesting

class HRCoderTests: XCTestCase {
    func getViewLayer() throws -> CALayer {
        try inWindowView(RainbowGlowView_Previews.previews) { view -> CALayer in
            _ = view.renderHierarchyAsPNG()
            return view.layer
        }
    }
    
    func getHumanJson(layer: CALayer) throws -> NSDictionary {
        try XCTUnwrap(
            HRCoder.archivedJSON(
                withRootObject: layer
            ) as? NSDictionary
        )
    }
    
    func testHumanCoderProduceStableJsonDictionary() throws {
        let dict1 = try getHumanJson(layer: getViewLayer())
        let dict2 = try getHumanJson(layer: getViewLayer())
        XCTContext.runActivity(named: "compare json objects") {
            $0.add(.init(plistObject: dict1))
            $0.add(.init(plistObject: dict2))
            XCTAssertEqual(dict1, dict2)
        }
    }
    
    func getJsonData(json: AnyObject) throws -> Data {
        try JSONSerialization.data(
            withJSONObject: json,
            options: [.prettyPrinted, .sortedKeys]
        )
    }
    
    func testHumanJsonData() throws {
        let jsonUrl = folderUrl().appendingPathComponent(".layers/RainbowGlowView.json")
        let expectedJsonData = try Data(contentsOf: jsonUrl)
        let actualJsonData = try getJsonData(json: getHumanJson(layer: getViewLayer()))
        XCTContext.runActivity(named: "compare json data") {
            $0.add(.init(data: actualJsonData, uniformTypeIdentifier: UTType.json.identifier))
            XCTAssertEqual(expectedJsonData, actualJsonData)
        }
    }
}
