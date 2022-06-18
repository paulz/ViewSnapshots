import Foundation
import ViewSnapshotTesting

class Principal: NSObject {
    override init() {
        super.init()
        logEnvironment()
        configureSnapshots()
    }
}

func logEnvironment() {
    NSLog("ProcessInfo.processInfo.environment")
    ProcessInfo.processInfo.environment.forEach {
        NSLog($0.key + "=" + $0.value)
    }
}

func configureSnapshots() {
    if runningOnXcodeCloud() {
        NSLog("""
              Configure Snapshots to load from Resouces
              since XCode Cloud runs tests on differenet environment from clone
              """)
        getSnapshotsFromResources()
    }
}

func runningOnXcodeCloud() -> Bool {
    ProcessInfo.processInfo.environment["CI_TEAM_ID"]?.isEmpty == false
}

func getSnapshotsFromResources() {
    let testBundle = Bundle(for: Principal.self)
    let snapshotsUrl = testBundle
        .resourceURL!
        .appendingPathComponent(snapshotsConfiguration.folderName)
    snapshotsConfiguration.folderUrl = snapshotsUrl
}
