//: labDeltaE shows difference in colors different by 1 step
//:
//: shown below a gray color image

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import PlaygroundSupport

let size = CGSize(width: 100, height: 100)
let rect = CGRect(origin: .zero, size: size)
let greenImage = CIImage.green.cropped(to: rect)
let almostGreen = CIColor(red: 0, green: 254.0/255, blue: 0)
let almostGreenImage = CIImage(color: almostGreen).cropped(to: rect)
let deltaFilter = CIFilter.labDeltaE()
deltaFilter.inputImage = greenImage
deltaFilter.image2 = almostGreenImage
let deltaImage = deltaFilter.outputImage!
let noAlpha = deltaImage.settingAlphaOne(in: deltaImage.extent)
//: [Next](@next)
