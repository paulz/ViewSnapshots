import XCTest
@testable import ViewSnapshotTesting
import SwiftUI
import Dynamic

class CAPackageViewTest: XCTestCase {
    let folderUrl = URL(fileURLWithPath: #filePath).deletingLastPathComponent()

    func test_UICAPackageView() throws {
        let packageUrl = folderUrl.appendingPathComponent("VisualTests/ContentView.caar")
        let view = Dynamic._UICAPackageView(contentsOfURL: packageUrl, publishedObjectViewClassMap: NSDictionary())
        let uiView: UIView = try XCTUnwrap(view.asInferred())
        let packageView = PackageView(view: uiView)
        verifySnapshot(packageView.frame(width: 300, height: 200), "PackageView")
    }
}

struct PackageView: UIViewRepresentable {
    let view: UIView
    func makeUIView(context: Context) -> UIView { view }
    func updateUIView(_ uiView: UIView, context: Context) {}
}
