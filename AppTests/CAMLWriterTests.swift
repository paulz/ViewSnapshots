import XCTest
import Dynamic
@testable import ExampleApp
@testable import ViewSnapshotTesting
import AEXML

class CAMLWriterTests: XCTestCase {
    func testWriteLayer() throws {
        let rainbowLayer = try getViewLayer(RainbowGlowView_Previews.previews).1
        let data = NSMutableData()
        let writer = Dynamic.CAMLWriter(data: data)
        writer.encodeObject(rainbowLayer)
        let actualXML = try AEXMLDocument(xml: data as Data)
        
        let folderUrl = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        let fileUrl = folderUrl.appendingPathComponent("RainbowGlowView.xml")
        let expectedData = try Data(contentsOf: fileUrl)
        let expectedXML = try AEXMLDocument(xml: expectedData)
        XCTAssertEqual(expectedXML.xml, actualXML.xml)
    }
}
