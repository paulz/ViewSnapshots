import HRCoder
import UniformTypeIdentifiers
import XCTest
@testable import ExampleApp
@testable import ViewSnapshotTesting
import SwiftUI

class HRCoderTests: XCTestCase {
    func getViewLayer() throws -> CALayer {
        try getViewLayer(RainbowGlowView_Previews.previews)
    }
    func getViewLayer<V: View>(_ view: V) throws -> CALayer {
        try inWindowView(view) { view -> CALayer in
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
    
    func testTextLayerAreSameWithDifferentContent() throws {
        let layer1 = try getViewLayer(Text("123").font(.system(.body, design: .monospaced)))
        let layer2 = try getViewLayer(Text("456").font(.system(.body, design: .monospaced)))
        try XCTAssertEqual(getHumanJson(layer: layer1), getHumanJson(layer: layer2))
    }
    
    func testCATextLayerContainsString() throws {
        try XCTAssertEqual(getHumanJson(layer: CATextLayer()), getHumanJson(layer: CATextLayer()))
        let layer1 = CATextLayer()
        layer1.string = "One"
        let dict1 = try getHumanJson(layer: layer1)
        XCTAssertEqual(dict1["string"] as? String, "One")
        try XCTAssertNotEqual(getHumanJson(layer: layer1), getHumanJson(layer: CATextLayer()))
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
