//: [Previous](@previous)
//:
//: Toggle Control rendered on Intel and Apple Silicon are not different perceptually
//:
//: But labDeltaE filter shows that they are different around knobs

import CoreImage
import CoreImage.CIFilterBuiltins

let size = CGSize(width: 100, height: 100)
let rect = CGRect(origin: .zero, size: size)
let intelImage = CIImage(image: #imageLiteral(resourceName: "ToggleView-intel.png"))
let m1Image = CIImage(image: #imageLiteral(resourceName: "ToggleView-m1.png"))
let deltaFilter = CIFilter.labDeltaE()
deltaFilter.inputImage = intelImage
deltaFilter.image2 = m1Image
let deltaImage = deltaFilter.outputImage!

let noAlpha = deltaImage.settingAlphaOne(in: deltaImage.extent)

//: [Next](@next)
