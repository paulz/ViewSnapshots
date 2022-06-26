//: [Previous](@previous)
//:
//: colorThreshold of 2.0 shows no difference between red and green???

import CoreImage
import CoreImage.CIFilterBuiltins

let size = CGSize(width: 100, height: 100)
let rect = CGRect(origin: .zero, size: size)
let greenImage = CIImage.green.cropped(to: rect)
let redImage = CIImage.red.cropped(to: rect)
let deltaFilter = CIFilter.labDeltaE()
deltaFilter.inputImage = greenImage
deltaFilter.image2 = redImage
let deltaImage = deltaFilter.outputImage!

let thresholdFilter = CIFilter.colorThreshold()
thresholdFilter.inputImage = deltaImage
thresholdFilter.threshold = 2.0
let thresholdImage = thresholdFilter.outputImage!

//: [Next](@next)
