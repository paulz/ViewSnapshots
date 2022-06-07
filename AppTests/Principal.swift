import Foundation
import ViewSnapshotTesting

class Principal: NSObject {
    override init() {
        super.init()
        configureSnapshots()
    }
}

func configureSnapshots() {
    let testBundle = Bundle(for: Principal.self)
    let snapshotsUrl = testBundle
        .resourceURL!
        .appendingPathComponent("Snapshots")
    snapshotsConfiguration.folderUrl = snapshotsUrl
}
