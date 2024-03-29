import XCTest
@testable import ExampleApp
@testable import ViewSnapshotTesting
import CoreImage
import SwiftUI

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
        deltaFilter.inputImage = intelImage.removeTransparency()
        deltaFilter.image2 = m1Image.removeTransparency()
        let deltaImage = try XCTUnwrap(deltaFilter.outputImage)
        try XCTContext.runActivity(named: "labDeltaE") { activity in
            let pngData = try XCTUnwrap(context.pngRepresentation(of: deltaImage, format: .RGBA8, colorSpace: sRGB))
            activity.add(pngData.pngAttachment())
        }
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
    
    func testLargeDeltaEvenColorDifferenceIsLessThen2Percent() throws {
        let delta = try calculateDelta("ToggleView")
#if arch(arm64)
        XCTAssertEqual(areaMaximum(delta.delta), [137, 137, 137, 137])
#else
        XCTAssertEqual(areaMaximum(delta.delta), [133, 133, 133, 133])
#endif
        
        let difference = try XCTUnwrap(diff(delta.first, delta.second).outputImage)
        XCTAssertEqual(ImageComparisonResult(difference: difference).maxColorDifference(), 0.015625)
    }
    
    func testLargeDifferenceEvenWhenColorHasNoDifference() throws {
        let delta = try calculateDelta("ContentView")
        let maxDifference: [UInt8] = [99, 99, 99, 99]
        XCTAssertEqual(areaMaximum(delta.delta), maxDifference)
        let diffPoint = CGPoint(x: 108, y: 52 - 24)
        let maxColor = getColor(delta.delta, at: diffPoint)
        XCTAssertEqual(maxColor, maxDifference)
        
        let firstColor = getColor(delta.first, at: diffPoint)
        XCTAssertEqual(firstColor, [79, 63, 0, 255])

        let secondColor = getColor(delta.second, at: diffPoint)
        XCTAssertEqual(secondColor, [79, 62, 0, 255])
        
        let difference = try XCTUnwrap(diff(delta.first, delta.second).outputImage)
        XCTAssertEqual(ImageComparisonResult(difference: difference).maxColorDifference(), 0)
    }
    
    func testLabDeltaE() {
        let deltaFilter = CIFilter.labDeltaE()
        let description = CIFilter.localizedDescription(forFilterName: deltaFilter.name)
        XCTAssertEqual(description, "Produces an image with the Lab ∆E difference values "
                       + "between two images. The result image will contain ∆E 1994 values "
                       + "between 0.0 and 100.0 where 2.0 is considered a just noticeable difference.")
    }
}
