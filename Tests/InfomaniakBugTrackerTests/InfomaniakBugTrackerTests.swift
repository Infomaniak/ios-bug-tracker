import InfomaniakCore
import InfomaniakDI
import InfomaniakLogin
import XCTest

@testable import InfomaniakBugTracker

class FakeTokenDelegate: RefreshTokenDelegate {
    func didUpdateToken(newToken: ApiToken, oldToken: ApiToken) {
        // Nothing to do
    }

    func didFailRefreshToken(_ token: ApiToken) {
        // Nothing to do
    }
}

final class InfomaniakBugTrackerTests: XCTestCase {
    @LazyInjectService var bugTracker: BugTracker
    var currentApiFetcher: ApiFetcher!

    override class func setUp() {
        let networkLoginService = Factory(type: InfomaniakNetworkLoginable.self) { _, _ in
            InfomaniakNetworkLogin(config: .init(clientId: ""))
        }
        SimpleResolver.sharedResolver.store(factory: networkLoginService)

        let bugTracker = Factory(type: BugTracker.self) { _, _ in
            BugTracker(info: BugTrackerInfo(project: "app-mobile-mail"))
        }
        SimpleResolver.sharedResolver.store(factory: bugTracker)
    }

    override func setUp() {
        currentApiFetcher = ApiFetcher()
        let token = ApiToken(accessToken: Env.token,
                             expiresIn: Int.max,
                             refreshToken: "",
                             scope: "",
                             tokenType: "",
                             userId: Env.userId,
                             expirationDate: Date(timeIntervalSinceNow: TimeInterval(Int.max)))
        currentApiFetcher.setToken(token, delegate: FakeTokenDelegate())
        bugTracker.configure(with: currentApiFetcher)
    }

    func testGetBuckets() async throws {
        let buckets = try await currentApiFetcher.buckets(project: "app-mobile-mail")
        XCTAssert(!buckets.list.isEmpty)
    }

    func testSendReport() async throws {
        let report = Report(bucketIdentifier: "app_mail",
                            type: .bugs,
                            priority: .normal,
                            subject: "Test",
                            description: "Please ignore me",
                            extra: bugTracker.extra,
                            files: [])
        let reportResult = try await currentApiFetcher.send(report: report)
        XCTAssert(!reportResult.url.isEmpty)
    }

    func testSendReportWithFile() async throws {
        let base64EncodedImage = "iVBORw0KGgoAAAANSUhEUgAAAAIAAAACCAYAAABytg0kAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAAOpgAAA6mAAAF3CculE8AAAAaGVYSWZNTQAqAAAACAAEAQYAAwAAAAEAAgAAARIAAwAAAAEAAQAAASgAAwAAAAEAAgAAh2kABAAAAAEAAAA+AAAAAAADoAEAAwAAAAEAAQAAoAIABAAAAAEAAAACoAMABAAAAAEAAAACAAAAAG/nOZEAAALgaVRYdFhNTDpjb20uYWRvYmUueG1wAAAAAAA8eDp4bXBtZXRhIHhtbG5zOng9ImFkb2JlOm5zOm1ldGEvIiB4OnhtcHRrPSJYTVAgQ29yZSA2LjAuMCI+CiAgIDxyZGY6UkRGIHhtbG5zOnJkZj0iaHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyI+CiAgICAgIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PSIiCiAgICAgICAgICAgIHhtbG5zOnRpZmY9Imh0dHA6Ly9ucy5hZG9iZS5jb20vdGlmZi8xLjAvIgogICAgICAgICAgICB4bWxuczpleGlmPSJodHRwOi8vbnMuYWRvYmUuY29tL2V4aWYvMS4wLyI+CiAgICAgICAgIDx0aWZmOkNvbXByZXNzaW9uPjE8L3RpZmY6Q29tcHJlc3Npb24+CiAgICAgICAgIDx0aWZmOlJlc29sdXRpb25Vbml0PjI8L3RpZmY6UmVzb2x1dGlvblVuaXQ+CiAgICAgICAgIDx0aWZmOk9yaWVudGF0aW9uPjE8L3RpZmY6T3JpZW50YXRpb24+CiAgICAgICAgIDx0aWZmOlBob3RvbWV0cmljSW50ZXJwcmV0YXRpb24+MjwvdGlmZjpQaG90b21ldHJpY0ludGVycHJldGF0aW9uPgogICAgICAgICA8ZXhpZjpQaXhlbFhEaW1lbnNpb24+MjwvZXhpZjpQaXhlbFhEaW1lbnNpb24+CiAgICAgICAgIDxleGlmOkNvbG9yU3BhY2U+MTwvZXhpZjpDb2xvclNwYWNlPgogICAgICAgICA8ZXhpZjpQaXhlbFlEaW1lbnNpb24+MjwvZXhpZjpQaXhlbFlEaW1lbnNpb24+CiAgICAgIDwvcmRmOkRlc2NyaXB0aW9uPgogICA8L3JkZjpSREY+CjwveDp4bXBtZXRhPgpbeBmTAAAAFUlEQVQIHWNQZWH8f9NM8D8TAxQAACkYA0sHOG6tAAAAAElFTkSuQmCC"
        let attachment = Data(base64Encoded: base64EncodedImage)!
        let report = Report(bucketIdentifier: "app_mail",
                            type: .bugs,
                            priority: .normal,
                            subject: "Test Image",
                            description: "Please ignore me",
                            extra: bugTracker.extra,
                            files: [ReportFile(name: "attachment.png", data: attachment, uti: .image)])
        let reportResult = try await currentApiFetcher.send(report: report)
        XCTAssert(!reportResult.url.isEmpty)
    }
}
