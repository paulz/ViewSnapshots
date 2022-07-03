import XCTest
import UniformTypeIdentifiers
@testable import ViewSnapshotTesting

func verifyCAML(expected: URL, actual: URL, file: StaticString = #filePath, line: UInt = #line) {
    let camlBundleName = actual.deletingPathExtension().lastPathComponent
    let fileManager = FileManager.default
    XCTContext.runActivity(named: camlBundleName) { activity in
        var isDirectory: ObjCBool = false
        func replaceExpected(message: String) {
            assertNoThrow {
                try? fileManager.createDirectory(at: expected.deletingLastPathComponent(),
                                                 withIntermediateDirectories: true)
                try? fileManager.removeItem(at: expected)
                try fileManager.copyItem(at: actual, to: expected)
                XCTFail("did not exist, now recorded", file: file, line: line)
            }
        }
        guard fileManager.fileExists(atPath: expected.path, isDirectory: &isDirectory), isDirectory.boolValue else {
            assertNoThrow {
                replaceExpected(message: "did not exist, now recorded")
            }
            return
        }
        if fileManager.contentsEqual(atPath: expected.path, andPath: actual.path) {
            return
        }
        assertNoThrow {
            let expectedContents = try fileManager.contents(of: expected)
            let actualContents = try fileManager.contents(of: actual)
            if expectedContents.count != actualContents.count {
                replaceExpected(message: "found \(actualContents.count) files," +
                                " while expecting \(expectedContents.count) - replacing")
            }
            for (expFile, actFile) in zip(expectedContents, actualContents) {
                guard !fileManager.contentsEqual(atPath: expFile.path, andPath: actFile.path) else {
                    continue
                }
                try XCTContext.runActivity(named: "compare " + expFile.lastPathComponent) { fileActivity in
                    let pngType = UTType.png
                    guard Set([expFile, actFile].map(\.pathExtension)) == [pngType.preferredFilenameExtension],
                          let expData = try? Data(contentsOf: expFile),
                          let actData = try? Data(contentsOf: actFile)
                    else {
                        var differentFilesmessage = "files are different"
                        if let actSize = actFile.fileSize,
                            let expSize = expFile.fileSize,
                            expSize != actSize {
                            differentFilesmessage += ", expected size: \(expSize), actual size: \(actSize)"
                        }
                        fileActivity.add(XCTAttachment(contentsOfFile: actFile))
                        try fileManager.removeItem(at: expFile)
                        try fileManager.copyItem(at: actFile, to: expFile)
                        XCTFail(differentFilesmessage, file: file, line: line)
                        return
                    }
                    let result = compare(expData, actData)
                    let differenceImage = result.difference
                    let distance = result.maxColorDifference()
                    let ciImage = differenceImage.premultiplyingAlpha().adjustExposure(amount: distance)
                    let context = CIContext(options: [
                        .workingColorSpace : workColorSpace,
                        .allowLowPower: NSNumber(booleanLiteral: false),
                        .highQualityDownsample: NSNumber(booleanLiteral: true),
                        .outputColorSpace: workColorSpace,
                        .useSoftwareRenderer: NSNumber(booleanLiteral: true),
                        .cacheIntermediates: NSNumber(booleanLiteral: false),
                        .priorityRequestLow: NSNumber(booleanLiteral: false),
                        .name: "difference"
                    ])
                    let data = context.pngRepresentation(of: ciImage, format: .RGBA8, colorSpace: workColorSpace)!
                    let diffAttachment = XCTAttachment(data: data, uniformTypeIdentifier: pngType.identifier)
                    diffAttachment.name = "difference"
                    fileActivity.add(diffAttachment)
                    
                    let actualAttachment = XCTAttachment(data: actData, uniformTypeIdentifier: pngType.identifier)
                    actualAttachment.name = "actual"
                    fileActivity.add(actualAttachment)
                    
                    let colorAccuracy = snapshotsConfiguration.colorAccuracy
                    if distance > colorAccuracy {
                        XCTFail(
                            """
                            images did not match
                            some pixels were different by \(distance * 100)% in color
                            max allowed difference in color: \(colorAccuracy * 100)%
                            see attached `difference` image between actual and expected
                            """,
                            file: file, line: line
                        )
                        try fileManager.removeItem(at: expFile)
                        try fileManager.copyItem(at: actFile, to: expFile)
                    }
                }
            }
        }
    }
}

func assertNoThrow<T>(_ expression:() throws -> T, file: StaticString = #file, line: UInt = #line) {
    XCTAssertNoThrow(try expression(), file: file, line: line)
}

extension FileManager {
    func contents(of directoryURL: URL) throws -> [URL] {
        let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey, .fileSizeKey])
        let directoryEnumerator = try XCTUnwrap(enumerator(
            at: directoryURL,
            includingPropertiesForKeys: Array(resourceKeys),
            options: .skipsHiddenFiles
        ))
         
        var fileURLs: [URL] = []
        for case let fileURL as URL in directoryEnumerator {
            guard let resourceValues = try? fileURL.resourceValues(forKeys: resourceKeys),
                resourceValues.isDirectory == false
                else {
                    continue
            }
            fileURLs.append(fileURL)
        }
        return fileURLs
    }
}

extension URL {
    var fileSize: Int? {
        try? resourceValues(forKeys: [.fileSizeKey]).fileSize
    }
}
