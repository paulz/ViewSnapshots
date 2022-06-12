import Foundation
import ViewSnapshotTesting

class Principal: NSObject {
    override init() {
        super.init()
        configureSnapshots()
    }
}

func runningOnXcodeCloud() -> Bool {
    ProcessInfo.processInfo.environment["CI_TEAM_ID"] != nil
}

func configureSnapshots() {
    if runningOnXcodeCloud() {
        getSnapshotsFromResources()
    }
}

func getSnapshotsFromResources() {
    let testBundle = Bundle(for: Principal.self)
    let snapshotsUrl = testBundle
        .resourceURL!
        .appendingPathComponent("Snapshots")
    snapshotsConfiguration.folderUrl = snapshotsUrl
}
