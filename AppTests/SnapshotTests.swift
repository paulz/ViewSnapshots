import XCTest
@testable import ExampleApp
import ViewSnapshotTesting
import SwiftUI

class SnapshotTests: XCTestCase {
    func testPreviews() throws {
//        verifySnapshot(ContentView_Previews.self)
//        verifySnapshot(PopularityBadge_Previews.self)
//        verifySnapshot(SettingsForm_Previews.self)
//        verifySnapshot(LayeringShadowsView_Previews.self)
        verifySnapshot(RainbowGlowView_Previews.self)
//        verifySnapshot(ToggleView_Previews.self, colorAccuracy: 0.032)
    }
    
    func testXcodeSVGassetNotMatchingPDf() {
        /**
         https://en.wikipedia.org/wiki/Test_card
            
            converted to PDF using: https://cloudconvert.com/svg-to-pdf
         
            demonstrates that SVG rendered incorrectly in Xcode Assets, missing central cicrcular pattern
            while PDF rendered perfectly and has smaller file size
            
         https://commons.wikimedia.org/wiki/File:Philips_PM5544.svg
         new versión by ebnz, CC BY-SA 3.0 <http://creativecommons.org/licenses/by-sa/3.0/>, via Wikimedia Commons
         */
        verifySnapshot(Image("Philips_PM5544_PDF"), "tv-set-test-pattern.pdf", colorAccuracy: 0.1)
        verifySnapshot(Image("Philips_PM5544_SVG"), "tv-set-test-pattern.svg", colorAccuracy: 0)
    }
}
