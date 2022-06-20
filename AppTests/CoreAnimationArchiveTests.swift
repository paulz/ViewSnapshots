import XCTest
@testable import ExampleApp
@testable import ViewSnapshotTesting

class CoreAnimationArchiveTests: XCTestCase {
    func testCoreAnimationArchiveIsSmallAndStableBeforeRendered() {
        let archiveData = getArchive(shouldRender: false)
        XCTAssertEqual(archiveData.count, 1325)
        XCTAssertEqual(archiveData.sha1string(), "037af7bb2d90b9307640150ac31962dd5c7b3112")
    }
    
    func getArchive(shouldRender: Bool) -> Data {
        try! inWindowView(RainbowGlowView_Previews.previews) { view -> Data in
            if shouldRender {
                _ = view.renderHierarchyAsPNG()
            }
            return try coreAnimationArchive(view: view)
        }
    }
    
    func getLayer(data: Data) throws -> CALayer {
        let topLevel = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data)
        let dict = try XCTUnwrap(topLevel as? NSDictionary)
        XCTAssertEqual(dict.allKeys as? [String], ["rootLayer"])
        return try XCTUnwrap(dict["rootLayer"] as? CALayer)
    }

    func testLayersAreNotEqual() throws {
        let archiveData = getArchive(shouldRender: true)
        let layer1 = try getLayer(data: archiveData)
        let layer2 = try getLayer(data: archiveData)
        XCTAssertNotEqual(layer1, layer2)
        XCTAssertFalse(layer1.isEqual(layer2))
    }
    
    func testUnarchiveLayer() throws {
        let archiveData = getArchive(shouldRender: true)
        let layer = try getLayer(data: archiveData)
        XCTAssertEqual(layer.bounds, .init(origin: .zero, size: .init(width: 300, height: 200)))
        XCTAssertEqual(layer.sublayers?.count, 9)
    }

    func testCoreAnimationArchiveAfterRenderIsNotStable() {
        let archiveData1 = getArchive(shouldRender: true)
        let archiveData2 = getArchive(shouldRender: true)
        XCTAssertEqual(archiveData1.count, 20261)
        XCTAssertNotEqual(archiveData1, archiveData2)
    }
    
    func plistData(_ plist: Any) throws -> Data {
        try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: .zero)
    }

    func plistFromData(_ data: Data) throws -> Any {
        var format: PropertyListSerialization.PropertyListFormat = .xml
        return try PropertyListSerialization.propertyList(from: data, format: &format)
    }

    func testArchiveXMLHasStableSerialization() throws {
        let caarData = getArchive(shouldRender: true)
        let plist1 = try plistFromData(caarData)
        let plist2 = try plistFromData(caarData)
        XCTAssertNotEqual(plist1 as? NSDictionary, plist2 as? NSDictionary,
                          "dictionaries are different as some objects are not comparable")

        try XCTContext.runActivity(named: "same plists") {
            $0.add(.init(plistObject: plist1))
            $0.add(.init(plistObject: plist2))
            let data1 = try plistData(plist1)
            let data2 = try plistData(plist2)
            XCTAssertEqual(data1, data2, "serialized XML plists are the same")
        }
    }
    func testSerializedXMLFromSameViewAreDifferent() throws {
        let caarData1 = getArchive(shouldRender: true)
        let caarData2 = getArchive(shouldRender: true)
        let plist1 = try plistFromData(caarData1)
        let plist2 = try plistFromData(caarData2)
        try XCTContext.runActivity(named: "different plists") {
            $0.add(.init(plistObject: plist1))
            $0.add(.init(plistObject: plist2))
            let data1 = try plistData(plist1)
            let data2 = try plistData(plist2)
            XCTAssertNotEqual(data1, data2, "serialized XML plists are different")
        }
    }
}

func coreAnimationArchive(view: UIView) throws -> Data {
    let archiver = NSKeyedArchiver(requiringSecureCoding: false)
    archiver.outputFormat = .binary
    archiver.encode(["rootLayer": view.layer], forKey: NSKeyedArchiveRootObjectKey)
    archiver.finishEncoding()
    return archiver.encodedData
}
