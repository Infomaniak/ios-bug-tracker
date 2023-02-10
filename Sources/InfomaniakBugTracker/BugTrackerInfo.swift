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

import Foundation
import InfomaniakCore

public enum AppReleaseType: String {
    case alpha = "Alpha"
    case beta = "Beta"
    case release = "Release"
}

public struct BugTrackerInfo {
    /// Route of the project bucket.
    let route: String?
    /// Project name.
    let project: String
    /// Service ID of the project bucket.
    let serviceId: Int?
    /// The name of the GitHub repo for release fetching.
    let gitHubRepoName: String?
    /// The app version name for comparison with GitHub.
    let appVersionName: String?

    /// Creates an object with the information needed by the Bug Tracker.
    /// - Parameters:
    ///   - route: Route of the project bucket.
    ///   - project: Project name.
    ///   - serviceId: Service ID of the project bucket.
    ///   - gitHubRepoName: The repo name as it is on GitHub.
    ///   - appReleaseType: Release type to build the version name.
    public init(route: String? = nil,
                project: String,
                serviceId: Int? = nil,
                gitHubRepoName: String? = nil,
                appReleaseType: AppReleaseType) {
        self.route = route
        self.project = project
        self.serviceId = serviceId
        self.gitHubRepoName = gitHubRepoName
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
        let appBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        self.appVersionName = "\(appReleaseType.rawValue)-\(appVersion)-b\(appBuild)"
    }
}
