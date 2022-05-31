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
    struct Delta {
        let first: CIImage
        let second: CIImage
        let delta: CIImage
    }
    let sRGB = CGColorSpace(name: CGColorSpace.sRGB)!
    lazy var context = CIContext(options: [
        .workingColorSpace : sRGB,
        .outputColorSpace: sRGB
    ])
    
    func calculateDelta(_ name: String) throws -> Delta {
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
        return Delta(
            first: deltaFilter.inputImage!,
            second: deltaFilter.image2!,
            delta: deltaImage
        )
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
        let toggleDelta = try calculateDelta("ToggleView")
        XCTAssertEqual(areaMaximum(toggleDelta.delta), [255, 255, 255, 255])
    }
    
    func testMaxDifferenceInContentViewIsLarge() throws {
        let toggleDelta = try calculateDelta("ContentView")
        XCTAssertEqual(areaMaximum(toggleDelta.delta), [99, 99, 99, 99])
    }
}
