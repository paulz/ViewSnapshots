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
                _ = view.renderLayerAsBitmap()
            }
            return try coreAnimationArchive(view: view)
        }
    }

    func testCoreAnimationArchiveAfterRenderIsNotStable() {
        let archiveData1 = getArchive(shouldRender: true)
        let archiveData2 = getArchive(shouldRender: true)
        XCTAssertEqual(archiveData1.count, 19316)
        XCTAssertNotEqual(archiveData1, archiveData2)
    }
    
    func testArchiveXMLAddsInstability() throws {
        let caarData = getArchive(shouldRender: true)
        var format: PropertyListSerialization.PropertyListFormat = .xml
        let plist1 = try PropertyListSerialization.propertyList(from: caarData, format: &format)
        let plist2 = try PropertyListSerialization.propertyList(from: caarData, format: &format)
        XCTAssertNotEqual(plist1 as? NSDictionary, plist2 as? NSDictionary)
    }
}

func coreAnimationArchive(view: UIView) throws -> Data {
    try NSKeyedArchiver.archivedData(
        withRootObject: ["rootLayer": view.layer],
        requiringSecureCoding: false
    )
}
