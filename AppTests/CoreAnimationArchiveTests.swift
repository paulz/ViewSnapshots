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
    
    func testUnarchiveLayer() throws {
        let archiveData = getArchive(shouldRender: true)
        let topLevel = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archiveData)
        let dict = try XCTUnwrap(topLevel as? NSDictionary)
        XCTAssertEqual(dict.allKeys as? [String], ["rootLayer"])
        let layer = try XCTUnwrap(dict["rootLayer"] as? CALayer)
        XCTAssertEqual(layer.bounds, .init(origin: .zero, size: .init(width: 300, height: 200)))
        XCTAssertEqual(layer.sublayers?.count, 9)
    }

    func testCoreAnimationArchiveAfterRenderIsNotStable() {
        let archiveData1 = getArchive(shouldRender: true)
        let archiveData2 = getArchive(shouldRender: true)
        XCTAssertEqual(archiveData1.count, 19316)
        XCTAssertNotEqual(archiveData1, archiveData2)
    }
    
    func testArchiveXMLHasStableSerialization() throws {
        let caarData = getArchive(shouldRender: true)
        var format: PropertyListSerialization.PropertyListFormat = .xml
        let plist1 = try PropertyListSerialization.propertyList(from: caarData, format: &format)
        let plist2 = try PropertyListSerialization.propertyList(from: caarData, format: &format)
        XCTContext.runActivity(named: "complare plists as dictionaries") {
            $0.add(.init(plistObject: plist1))
            $0.add(.init(plistObject: plist2))
        }
        XCTAssertNotEqual(plist1 as? NSDictionary, plist2 as? NSDictionary,
                          "dictionaries are different as some objects are not comparable")
        
        let data1 = try PropertyListSerialization.data(fromPropertyList: plist1, format: .xml, options: .zero)
        let data2 = try PropertyListSerialization.data(fromPropertyList: plist2, format: .xml, options: .zero)
        XCTAssertEqual(data1, data2, "serialized XML plists are the same")
    }
}

func coreAnimationArchive(view: UIView) throws -> Data {
    try NSKeyedArchiver.archivedData(
        withRootObject: ["rootLayer": view.layer],
        requiringSecureCoding: false
    )
}
