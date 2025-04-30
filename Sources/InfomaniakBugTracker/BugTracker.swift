/*
 Infomaniak Bug Tracker - iOS
 Copyright (C) 2021 Infomaniak Network SA

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import InfomaniakCore
import OSLog
import SwiftUI
import UIKit
import VersionChecker

/// Bug Tracker class containing information needed by the library.
public class BugTracker {
    var info: BugTrackerInfo
    var apiFetcher: ApiFetcher?
    var screenshotObserver: NSObjectProtocol?
    var userAgent = "InfomaniakBugTracker/1"

    /// Extra info dictionary sent along with every bug report.
    var extra: [String: String] {
        return [
            "project": info.project,
            "route": info.route ?? "null",
            "userAgent": userAgent,
            "platform": UIDevice.current.systemName,
            "os_version": UIDevice.current.systemVersion,
            "device": UIDevice.modelName,
            "app_version": Bundle.main.releaseVersionNumber,
            "app_build_number": Bundle.main.buildVersionNumber
        ]
    }

    /// Configure the instance by setting the info object.
    /// - Parameter info: New info object
    public init(info: BugTrackerInfo) {
        self.info = info
    }

    /// Set the ApiFetcher for the current user.
    /// - Parameter apiFetcher: ApiFetcher for the current user
    public func configure(with apiFetcher: ApiFetcher) {
        self.apiFetcher = apiFetcher
    }

    /// Starts observing when the user takes a screenshot to present the bug tracker view automatically.
    public func activateOnScreenshot(willPresent: (() -> Void)? = nil) {
        NotificationCenter.default.removeObserver(screenshotObserver as Any)
        screenshotObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: .main
        ) { _ in
            let keyWindow = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .compactMap { $0 as? UIWindowScene }
                .flatMap(\.windows)
                .first(where: \.isKeyWindow)

            guard let visibleViewController = keyWindow?.visibleViewController else {
                Logger.general.warning("Screenshot detected but no view controller to present from found")
                return
            }

            let snapshot = keyWindow?.makeSnapshot()

            // Present alert asking for bug report
            let alertController = UIAlertController(
                title: Translation.alertReportScreenshotTitle,
                message: nil,
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: Translation.buttonYes, style: .default) { _ in
                willPresent?()
                var files = [ReportFile]()
                if let snapshot = snapshot, let file = try? ReportFile.from(image: snapshot, named: "screenshot_automatic") {
                    files.append(file)
                }
                visibleViewController.present(BugTrackerViewController(files: files), animated: true)
            })
            alertController.addAction(UIAlertAction(title: Translation.buttonNo, style: .cancel))
            visibleViewController.present(alertController, animated: true)
        }
    }

    /// Stops observing when the user takes a screenshot.
    public func stopActivatingOnScreenshot() {
        NotificationCenter.default.removeObserver(screenshotObserver as Any)
    }

    func buckets(route: String? = nil, project: String, serviceId: Int? = nil) async throws -> Buckets {
        guard let apiFetcher else { fatalError("BugTracker must be configured with an ApiFetcher") }
        return try await apiFetcher.buckets(route: route, project: project, serviceId: serviceId)
    }

    func send(report: Report) async throws -> ReportResult {
        guard let apiFetcher else { fatalError("BugTracker must be configured with an ApiFetcher") }
        let subjectPrefix = "[iOS]: "
        var reportCopy = report
        if !reportCopy.subject.hasPrefix(subjectPrefix) {
            reportCopy.subject = "\(subjectPrefix)\(reportCopy.subject)"
        }
        if reportCopy.description.isEmpty {
            reportCopy.description = "Pas de description fournie"
        }

        return try await apiFetcher.send(report: reportCopy)
    }

    func isAppOutdated() async throws -> Bool {
        let versionStatus = try await VersionChecker.standard.checkAppVersionStatus()
        return versionStatus != .isUpToDate
    }
}
