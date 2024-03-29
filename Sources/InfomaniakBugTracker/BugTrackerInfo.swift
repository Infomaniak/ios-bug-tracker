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

public struct BugTrackerInfo {
    /// Route of the project bucket.
    let route: String?
    /// Project name.
    let project: String
    /// Service ID of the project bucket.
    let serviceId: Int? /// The app version name for comparison with GitHub.

    /// Creates an object with the information needed by the Bug Tracker.
    /// - Parameters:
    ///   - route: Route of the project bucket.
    ///   - project: Project name.
    ///   - serviceId: Service ID of the project bucket.
    ///   - gitHubRepoName: The repo name as it is on GitHub.
    ///   - appReleaseType: Release type to build the version name.
    public init(route: String? = nil,
                project: String,
                serviceId: Int? = nil) {
        self.route = route
        self.project = project
        self.serviceId = serviceId
    }
}
