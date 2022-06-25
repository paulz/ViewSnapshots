import XCTest

class ColorThresholdTests: XCTestCase {
    let thresholdFilter = CIFilter.colorThreshold()
    
    func testLocalizedDescription() throws {
        let description = CIFilter.localizedDescription(forFilterName: thresholdFilter.name)
        XCTAssertEqual(description, "Produces a binarized image from an image and a threshold value. "
                       + "The red, green and blue channels of the resulting image will be one "
                       + "if its value is greater than the threshold and zero otherwise.")
    }
    func testColorEquality() {
        XCTAssertEqual(CIColor.red, CIColor.red)
        XCTAssertEqual("1 0 0 1", CIColor.red.stringRepresentation)
        XCTAssertEqual(CIColor.green, CIColor(red: 0, green: 1, blue: 0, alpha: 1))
    }
    let onePixel = CGRect(origin: .zero, size: .init(width: 100, height: 100))
    
    func testLabDeltaRedAndGreen() {
        let greenImage = CIImage.green.cropped(to: onePixel)
        XCTAssertEqual([0, 255, 0, 255], getColor(greenImage))
        let redImage = CIImage.red.cropped(to: onePixel)
        XCTAssertEqual([255, 0, 0, 255], getColor(redImage))
        let deltaFilter = CIFilter.labDeltaE()
        deltaFilter.inputImage = greenImage
        deltaFilter.image2 = redImage
        let deltaImage = deltaFilter.outputImage!
        XCTAssertEqual([255, 255, 255, 255], getColor(deltaImage))
        
        let thresholdImage = deltaImage.threshold(2.0)
        XCTAssertEqual([0, 0, 0, 255], getColor(thresholdImage))

        XCTAssertEqual([255, 255, 255, 255], getColor(deltaImage.threshold(1.0 - Float.leastNonzeroMagnitude)))
        XCTAssertEqual([0, 0, 0, 255], getColor(deltaImage.threshold(1.00001)))
    }

    func testLabDeltaSimilarColors() {
        let greenImage = CIImage.green.cropped(to: onePixel)
        XCTAssertEqual([0, 255, 0, 255], getColor(greenImage))
        let green2Image = CIImage(color: CIColor(red: 0, green: 0.99, blue: 0, alpha: 1)).cropped(to: onePixel)
        XCTAssertEqual([0, 252, 0, 255], getColor(green2Image))
        let deltaFilter = CIFilter.labDeltaE()
        deltaFilter.inputImage = greenImage
        deltaFilter.image2 = green2Image
        let deltaImage = deltaFilter.outputImage!.settingAlphaOne(in: onePixel)
        XCTAssertEqual([90, 90, 90, 255], getColor(deltaImage))
        
        let thresholdImage = deltaImage.threshold(2.0)
        XCTAssertEqual([0, 0, 0, 255], getColor(thresholdImage))

        XCTAssertEqual([255, 255, 255, 255], getColor(deltaImage.threshold(0.35)))
        XCTAssertEqual([0, 0, 0, 255], getColor(deltaImage.threshold(0.36)))
    }

    lazy var context = CIContext(options: [
        .workingColorSpace : colorSpace,
        .outputColorSpace: colorSpace,
        .workingFormat: NSNumber(value: CIFormat.RGBA8.rawValue)
    ])

    let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

    func getColor(_ image: CIImage, at point: CGPoint = .zero) -> [UInt8] {
        var data = Data(repeating: 0, count: 4)
        data.withUnsafeMutableBytes { ptr in
            context.render(
                image,
                toBitmap: ptr.baseAddress!,
                rowBytes: 4,
                bounds: CGRect(origin: point, size: CGSize(width: 1, height: 1)),
                format: .RGBA8,
                colorSpace: colorSpace)
        }
        return [UInt8](data)
    }
}

extension CIImage {
    func threshold(_ value: Float) -> CIImage {
        let thresholdFilter = CIFilter.colorThreshold()
        thresholdFilter.inputImage = self
        thresholdFilter.threshold = value
        return thresholdFilter.outputImage!
    }
}
