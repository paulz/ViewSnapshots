import XCTest

class ColorThresholdTests: XCTestCase {
    let thresholdFilter = CIFilter.colorThreshold()
    
    func testLocalizedDescription() throws {
        let description = CIFilter.localizedDescription(forFilterName: thresholdFilter.name)
        XCTAssertEqual(description, "Produces a binarized image from an image and a threshold value. "
                       + "The red, green and blue channels of the resulting image will be one "
                       + "if its value is greater than the threshold and zero otherwise.")
    }    
}
