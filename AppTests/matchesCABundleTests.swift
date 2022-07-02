import XCTest
@testable import ViewSnapshotTesting
@testable import ExampleApp
import SwiftUI
import AEXML

class matchesCABundleTests: XCTestCase {
    func testSnapshots() {
        SnapshotsConfiguration.withColorAccuracy(0) {
            matchesCABundle(ToggleView_Previews.self)
            matchesCABundle(RainbowGlowView_Previews.self)
            matchesCABundle(ContentView_Previews.self)
            matchesCABundle(PopularityBadge_Previews.self)
            matchesCABundle(SettingsForm_Previews.self)
            matchesCABundle(LayeringShadowsView_Previews.self)
        }
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

func matchesCABundle<V>(_ view: V.Type = V.self) where V: PreviewProvider {
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
    let folderUrl = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .appendingPathComponent("CoreAnimationBundles")
    let bundleUrl = folderUrl.appendingPathComponent(bundleName)
    verifyCAML(expected: bundleUrl, actual: URL(fileURLWithPath: tempBundlePath))
}

func standardize(xmlFilePath: String) {
    assertNoThrow {
        let doc = try AEXMLDocument(xml: Data(contentsOf: URL(fileURLWithPath: xmlFilePath)))
        let withSimpleBackdropGroupName = doc.xml.replacingOccurrences(
            of: #"groupName=".+ Backdrop Group""#,
            with: #"groupName="Backdrop Group""#,
            options: .regularExpression)
        try withSimpleBackdropGroupName.write(toFile: xmlFilePath, atomically: true, encoding: .utf8)
    }
}
