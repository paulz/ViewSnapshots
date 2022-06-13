import XCTest
@testable import ExampleApp
@testable import ViewSnapshotTesting

class CoreAnimationArchiveTests: XCTestCase {
    func testCoreAnimationArchive() {
        let archiveData = try! inWindowView(RainbowGlowView_Previews.previews) {
            try coreAnimationArchive(view: $0)
        }
        XCTAssertEqual(archiveData.count, 1325)
        XCTAssertEqual(archiveData.sha1string(), "037af7bb2d90b9307640150ac31962dd5c7b3112")
    }
}

func coreAnimationArchive(view: UIView) throws -> Data {
    try NSKeyedArchiver.archivedData(
        withRootObject: ["rootLayer": view.layer],
        requiringSecureCoding: false
    )
}

import CommonCrypto

extension Data {
    func sha1string() -> String {
        sha1().map { String(format: "%02hhx", $0) }.joined()
    }

    func sha1() -> [UInt8] {
        var digest = [UInt8](repeating: 0, count:Int(CC_SHA1_DIGEST_LENGTH))
        withUnsafeBytes {
            _ = CC_SHA1($0.baseAddress, CC_LONG(count), &digest)
        }
        return digest
    }
}
