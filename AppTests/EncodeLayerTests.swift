import XCTest
@testable import ViewSnapshotTesting
@testable import ExampleApp

class EncodeLayerTests: XCTestCase {
    let folderUrl = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
    let fileManager = FileManager.default

    func layer(caar archiveName: String) throws -> CALayer {
        let caarUrl = folderUrl.appendingPathComponent("VisualTests/\(archiveName).caar")
        let caarData = try Data(contentsOf: caarUrl)
        let decoded = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(caarData)
        let dict = try XCTUnwrap(decoded as? NSDictionary)
        return try XCTUnwrap(dict["rootLayer"] as? CALayer)
    }
    
    func testCAMLEncodeLayerTreeToPathWithInfoCreatesCAMLBundle() throws {
        let viewName = "ContentView"
        let layer = try layer(caar: viewName)
        let bundleName = viewName + ".ca"
        let tempBundlePath = "/tmp/" + bundleName
        let exported = CAMLEncodeLayerTreeToPathWithInfo(layer, tempBundlePath, nil)
        XCTAssertTrue(exported, "CAML export successful")

        let bundleUrl = folderUrl.appendingPathComponent(bundleName)
        let same = fileManager.contentsEqual(atPath: tempBundlePath, andPath: bundleUrl.path)
        XCTAssertTrue(same, "exported bundle match expected")
    }
    
    func testCAEncodeLayerTreeWithInfoCreatesArchiveWithRootLayer() throws {
        let layer = try layer(caar: "ContentView")
        let data = CAEncodeLayerTreeWithInfo(layer, nil)
        let decoded = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
        let dict = try XCTUnwrap(decoded as? NSDictionary)
        XCTAssertEqual(dict.allKeys as? [String], ["rootLayer", "geometryFlipped"])
        XCTAssertEqual(dict["geometryFlipped"] as? Bool, true)
    }
    
    func testExportRenderedSavesNoAssetsEvenWhenViewIsRendered() throws {
        let bundlePath = "/tmp/no-assets.ca"
        try inWindowView(ContentView_Previews.previews) { view  in
            let data = view.renderHierarchyAsPNG()
            XCTAssertGreaterThanOrEqual(data.count, 6181)
            let exported = CAMLEncodeLayerTreeToPathWithInfo(view.layer, "/tmp/no-assets.ca", nil)
            XCTAssertTrue(exported)
        }
        let assetsPath = bundlePath + "/assets"
        let noAssets = try fileManager.contentsOfDirectory(atPath: assetsPath)
        XCTAssertEqual(0, noAssets.count)
        let caml = try String(contentsOfFile: bundlePath + "/main.caml")
        XCTAssertTrue(caml.contains(#"<contents type="CATintedImage"/>"#))
    }
}
