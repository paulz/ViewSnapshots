import Foundation
import CommonCrypto
import XCTest
import UniformTypeIdentifiers

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

    func pngAttachment() -> XCTAttachment {
        XCTAttachment(data: self, uniformTypeIdentifier: UTType.png.identifier)
    }
}
