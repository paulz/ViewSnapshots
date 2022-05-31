import XCTest
@testable import ExampleApp
@testable import ViewSnapshotTesting
import CoreImage
import SwiftUI

extension CIImage {
    func settingAlphaOne() -> CIImage {
        settingAlphaOne(in: extent)
    }
}

class PerceptualDifferencesTest: XCTestCase {
    let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!
    lazy var context = CIContext(options: [
        .workingColorSpace : sRGB,
        .outputColorSpace: sRGB
    ])

    func labDelta(_ name: String) throws -> CIImage {
        let options: [CIImageOption : Any] = [
            .colorSpace: sRGB
        ]

        let intelUrl = folderUrl().appendingPathComponent("\(name)-intel.png")
        let m1Url = folderUrl().appendingPathComponent("\(name)-m1.png")
        let intelImage = try XCTUnwrap(CIImage(contentsOf: intelUrl, options: options))
        let m1Image = try XCTUnwrap(CIImage(contentsOf: m1Url, options: options))

        let deltaFilter = CIFilter.labDeltaE()
        deltaFilter.inputImage = intelImage.settingAlphaOne()
        deltaFilter.image2 = m1Image.settingAlphaOne()
        let deltaImage = try XCTUnwrap(deltaFilter.outputImage)
        let deltaUrl = folderUrl().appendingPathComponent("\(name)-labDelta.png")
        try context.writePNGRepresentation(
            of: deltaImage, to: deltaUrl, format: .RGBA8, colorSpace: sRGB
        )
        XCTAssertEqual(m1Image.properties as NSDictionary, intelImage.properties as NSDictionary)
        return deltaImage
    }
    
    func areaMaximum(_ image: CIImage) -> [UInt8] {
        let filter = CIFilter.areaMaximum()
        filter.inputImage = image
        filter.setValue(CIVector(cgRect: image.extent), forKey: kCIInputExtentKey)
        return getColor(filter.outputImage!)
    }
    
    func getColor(_ image: CIImage, at point: CGPoint = .zero) -> [UInt8] {
        var data = Data(repeating: 0, count: 4)
        data.withUnsafeMutableBytes { ptr in
            context.render(
                image,
                toBitmap: ptr.baseAddress!,
                rowBytes: 4,
                bounds: CGRect(origin: point, size: CGSize(width: 1, height: 1)),
                format: .RGBA8,
                colorSpace: sRGB)
        }
        return [UInt8](data)
    }
    
    func testMaxDifferenceInToggleViewIsLarge() throws {
        let toggleDelta = try labDelta("ToggleView")
        XCTAssertEqual(areaMaximum(toggleDelta), [255, 255, 255, 255])
    }
    
    func testMaxDifferenceInContentViewIsLarge() throws {
        let toggleDelta = try labDelta("ContentView")
        XCTAssertEqual(areaMaximum(toggleDelta), [99, 99, 99, 99])
    }
}
