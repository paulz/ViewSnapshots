import XCTest
import AEXML

class CAMLdocumentTests: XCTestCase {
    func testUpdateTintImage() throws {
        let tintAttributeXML = """
        <contents tint="0 0 0" type="CATintedImage">
            <image A8asL8="1" src="assets/image4.png" />
        </contents>
        """
        let doc = try AEXMLDocument(xml: tintAttributeXML)
        standardizeTintedImages(doc: doc)
        XCTAssertEqual(doc.xmlSpaces,
        """
        <?xml version="1.0" encoding="utf-8" standalone="no"?>
        <contents type="CATintedImage">
            <image A8asL8="1" src="assets/image4.png" />
            <tint tint="0 0 0" type="CGColor" />
        </contents>
        """,
        "should convert attribute to tint element")
    }

    func testReplacement() {
        let xmlString = #"groupName="&lt;SwiftUI.UIKitNavigationController:0x7fefa506ee00&gt; Backdrop Group""#
        let result = xmlString.replacingOccurrences(
            of: #"groupName=".+ Backdrop Group""#,
            with: #"groupName="Backdrop Group""#,
            options: .regularExpression)
        XCTAssertEqual(#"groupName="Backdrop Group""#, result)
    }
}
