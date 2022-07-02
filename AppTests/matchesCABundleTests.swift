import XCTest
@testable import ViewSnapshotTesting
@testable import ExampleApp
import SwiftUI

class matchesCABundleTests: XCTestCase {
    func testSnapshots() {
        matchesCABundle(ToggleView_Previews.self)
        matchesCABundle(RainbowGlowView_Previews.self)
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
    let folderUrl = URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .appendingPathComponent("CoreAnimationBundles")
    let bundleUrl = folderUrl.appendingPathComponent(bundleName)
    verifyCAML(expected: bundleUrl, actual: URL(fileURLWithPath: tempBundlePath))
}
