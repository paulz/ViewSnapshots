//: labDeltaE shows no difference between image of same color
//:
//: shown below as black square

import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import PlaygroundSupport

let size = CGSize(width: 100, height: 100)
let rect = CGRect(origin: .zero, size: size)
let greenImage = CIImage.green.cropped(to: rect)
let deltaFilter = CIFilter.labDeltaE()
deltaFilter.inputImage = greenImage
deltaFilter.image2 = greenImage
let deltaImage = deltaFilter.outputImage!
let noAlpha = deltaImage.settingAlphaOne(in: deltaImage.extent)

//: [Next](@next)
