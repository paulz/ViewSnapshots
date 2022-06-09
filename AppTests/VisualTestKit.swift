import XCTest
import VisualTestKit


extension XCTestCase {

    func VTKSetReferenceImagesDirectory(_ path: String?) {
        __VTKSetReferenceImagesDirectory(path, self)
    }

    func VTKAssertView(_ view: UIView, name: String, file: String = #file, line: UInt = #line) {
        VTKAssertView(view, name: name, decorations: [], file: file, line: line)
    }
    func VTKAssertView(_ view: UIView,
                       name: String,
                       decorations: VTKAssertIDDecorations,
                       file: String = #file,
                       line: UInt = #line) {
        visualTestKitAssert.assertView(
            view,
            identifier: VTKID(name, decorations),
            filePath: file,
            lineNumber: UInt64(line)
        )
    }
}
