import XCTest
import UniformTypeIdentifiers

class HardwareTest: XCTestCase {
    func testHardware() throws {
        let attachment = XCTAttachment(
            contentsOfFile: URL(fileURLWithPath: "/tmp/hardware-info.txt"),
            uniformTypeIdentifier: UTType.text.identifier
        )
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
