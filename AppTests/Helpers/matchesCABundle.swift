import AEXML
import SwiftUI
@testable import ViewSnapshotTesting

func matchesCABundle<V>(_ view: V.Type = V.self, file: StaticString = #filePath, line: UInt = #line) where V: PreviewProvider {
    let viewName = "\(V.self)".components(separatedBy: "_Previews").first!
    let bundleName = viewName + ".ca"
    let tempBundlePath = "/tmp/" + bundleName
    assertNoThrow {
        try inWindowView(V.previews) { view  in
            view.vtk_Snapshot()
            CAMLEncodeLayerTreeToPathWithInfo(view.layer, tempBundlePath, nil)
        }
    }
    standardize(xmlFilePath: tempBundlePath + "/main.caml")
    let folderUrl = URL(fileURLWithPath: String(describing: file))
        .deletingLastPathComponent()
        .appendingPathComponent("CoreAnimationBundles")
    let bundleUrl = folderUrl.appendingPathComponent(bundleName)
    verifyCAML(expected: bundleUrl, actual: URL(fileURLWithPath: tempBundlePath), file: file, line: line)
}

func standardize(xmlFilePath: String) {
    assertNoThrow {
        let doc = try AEXMLDocument(xml: Data(contentsOf: URL(fileURLWithPath: xmlFilePath)))
        standardizeTintedImages(doc: doc)
        let withSimpleBackdropGroupName = doc.xml.replacingOccurrences(
            of: #"groupName=".+ Backdrop Group""#,
            with: #"groupName="Backdrop Group""#,
            options: .regularExpression)
        try withSimpleBackdropGroupName.write(toFile: xmlFilePath, atomically: true, encoding: .utf8)
    }
}

func standardizeTintedImages(doc: AEXMLDocument) {
    doc.allDescendants {
        $0.attributes["type"] == "CATintedImage"
    }.forEach(updateTintedImage(element:))
}

func updateTintedImage(element: AEXMLElement) {
    if let tint = element.attributes["tint"] {
        element.attributes["tint"] = nil
        element.addChild(
            name: "tint",
            attributes: [
                "type" : "CGColor",
                "value" : tint
            ]
        )
    }
    if let image = element.children.first(where: {$0.name == "image"}),
       image.attributes["type"] == nil {
        image.attributes["type"] = "CGImage"
    }
}
