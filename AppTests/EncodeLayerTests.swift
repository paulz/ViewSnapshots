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
        let viewName = "ContentView-fromCAAR"
        let layer = try layer(caar: "ContentView")
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
    
    func testCAMLEncodeLayerTreeToPathWithInfoFromSnapshot() throws {
        let viewName = "ContentView-fromSnapshot"
        let bundleName = viewName + ".ca"
        let tempBundlePath = "/tmp/" + bundleName

        try inWindowView(ContentView_Previews.previews) { view  in
            view.vtk_Snapshot()
            CAMLEncodeLayerTreeToPathWithInfo(view.layer, tempBundlePath, nil)
        }
        let bundleUrl = folderUrl.appendingPathComponent(bundleName)
        let same = fileManager.contentsEqual(atPath: tempBundlePath, andPath: bundleUrl.path)
        XCTAssertTrue(same, "exported bundle match expected")
    }
    
    func testCAMLEncodeToggleView() throws {
        let viewName = "ToggleView-fromSnapshot"
        let bundleName = viewName + ".ca"
        let tempBundlePath = "/tmp/" + bundleName

        try inWindowView(ToggleView_Previews.previews) { view  in
            view.vtk_Snapshot()
            CAMLEncodeLayerTreeToPathWithInfo(view.layer, tempBundlePath, nil)
        }
        let bundleUrl = folderUrl.appendingPathComponent(bundleName)
        verifyCAML(expected: bundleUrl, actual: URL(fileURLWithPath: tempBundlePath))
    }
}

func verifyCAML(expected: URL, actual: URL, file: StaticString = #filePath, line: UInt = #line) {
    let camlBundleName = actual.deletingPathExtension().lastPathComponent
    let fileManager = FileManager.default
    XCTContext.runActivity(named: camlBundleName) { activity in
        if fileManager.contentsEqual(atPath: expected.path, andPath: actual.path) {
            return
        }
        assertNoThrow {
            let expectedContents = try fileManager.contents(of: expected)
            let actualContents = try fileManager.contents(of: actual)
            XCTAssertEqual(expectedContents.count, actualContents.count,
                           "found \(actualContents.count) files, while expecting \(expectedContents.count)",
                           file: file, line: line)
            for (expFile, actFile) in zip(expectedContents, actualContents) {
                XCTAssertTrue(fileManager.contentsEqual(atPath: expFile.path, andPath: actFile.path),
                              "file: \(expFile.lastPathComponent) is different",
                              file: file,
                              line: line)
            }
        }
    }
}

func assertNoThrow<T>(_ expression:() throws -> T, file: StaticString = #file, line: UInt = #line) {
    XCTAssertNoThrow(try expression(), file: file, line: line)
}

extension FileManager {
    func contents(of directoryURL: URL) throws -> [URL] {
        let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey])
        let directoryEnumerator = try XCTUnwrap(enumerator(
            at: directoryURL,
            includingPropertiesForKeys: Array(resourceKeys),
            options: .skipsHiddenFiles
        ))
         
        var fileURLs: [URL] = []
        for case let fileURL as URL in directoryEnumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                resourceValues.isDirectory == false
                else {
                    continue
            }
            fileURLs.append(fileURL)
        }
        return fileURLs
    }
}
