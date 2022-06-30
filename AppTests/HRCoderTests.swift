import HRCoder
import UniformTypeIdentifiers
import XCTest
@testable import ExampleApp
@testable import ViewSnapshotTesting
import SwiftUI
import Dynamic
import QuartzCore

func getViewLayer<V: View>(_ view: V) throws -> (Data, CALayer) {
    try inWindowView(view) { view -> (Data, CALayer) in
        (view.renderHierarchyAsPNG(), view.layer)
    }
}

func getViewLayer() throws -> CALayer {
    try getViewLayer(RainbowGlowView_Previews.previews).1
}

class HRCoderTests: XCTestCase {
    func getHumanJson(layer: CALayer) throws -> NSDictionary {
        try XCTUnwrap(
            HRCoder.archivedJSON(
                withRootObject: ["rootLayer": layer]
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
        let layer1 = try getViewLayer(Text("123").font(.system(.body, design: .monospaced))).1
        let layer2 = try getViewLayer(Text("456").font(.system(.body, design: .monospaced))).1
        try XCTAssertEqual(getHumanJson(layer: layer1), getHumanJson(layer: layer2))
    }
    
    func testCATextLayerContainsString() throws {
        try XCTAssertEqual(getHumanJson(layer: CATextLayer()), getHumanJson(layer: CATextLayer()))
        let layer1 = CATextLayer()
        layer1.string = "One"
        let dict1 = try getHumanJson(layer: layer1)
        XCTAssertEqual(dict1.value(forKeyPath: "rootLayer.string") as? String, "One")
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
    
    func testConvertCoreAnimationArchive() throws {
        let folderUrl = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let caarUrl = folderUrl.appendingPathComponent("VisualTests/ContentView.caar")
        let caarData = try Data(contentsOf: caarUrl)
        let decoded = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(caarData)
        let dict = try XCTUnwrap(decoded as? NSDictionary)
        let archived = try XCTUnwrap(HRCoder.archivedJSON(withRootObject: dict) as? NSDictionary)
        let jsonData = try getJsonData(json: archived)
        
        let expectedUrl = folderUrl.appendingPathComponent("ContentView-withTintedImage.json")
        let expectedData = try Data(contentsOf: expectedUrl)
        XCTAssertEqual(expectedData, jsonData)
    }
}
