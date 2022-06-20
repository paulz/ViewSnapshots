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
    
    func getHumanJson() throws -> NSDictionary {
        try XCTUnwrap(
            HRCoder.archivedJSON(
                withRootObject: getViewLayer()
            ) as? NSDictionary
        )
    }
    
    func testHumanCoderProduceStableJsonDictionary() throws {
        let dict1 = try getHumanJson()
        let dict2 = try getHumanJson()
        XCTContext.runActivity(named: "compare json objects") {
            $0.add(.init(plistObject: dict1))
            $0.add(.init(plistObject: dict2))
            XCTAssertEqual(dict1, dict2)
        }
    }
    
    func getHumanJsonData() throws -> Data {
        try JSONSerialization.data(
            withJSONObject: getHumanJson(),
            options: [.prettyPrinted, .sortedKeys]
        )
    }
    
    func testHumanJsonData() throws {
        let jsonUrl = folderUrl().appendingPathComponent("RainbowGlowView.json")
        let expectedJsonData = try Data(contentsOf: jsonUrl)
        let actualJsonData = try getHumanJsonData()
        XCTContext.runActivity(named: "compare json data") {
            $0.add(.init(data: actualJsonData, uniformTypeIdentifier: UTType.json.identifier))
            XCTAssertEqual(expectedJsonData, actualJsonData)
        }
    }
}
