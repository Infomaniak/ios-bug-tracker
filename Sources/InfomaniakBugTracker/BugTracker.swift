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

import UIKit

/// Bug Tracker class containing information needed by the library.
public class BugTracker {
    /// Shared Bug Tracker class instance.
    public static let instance = BugTracker()

    var info: BugTrackerInfo?
    var userAgent = "InfomaniakBugTracker/1"

    /// Extra info dictionary sent along with every bug report.
    var extra: [String: String] {
        return [
            "project": info?.project ?? "null",
            "route": info?.route ?? "null",
            "userAgent": BugTracker.instance.userAgent,
            "platform": UIDevice.current.systemName,
            "os_version": UIDevice.current.systemVersion,
            "device": UIDevice.modelName,
            "app_version": Bundle.main.releaseVersionNumber,
            "app_build_number": Bundle.main.buildVersionNumber
        ]
    }

    private init() {}
    
    /// Configure the instance by setting the info object.
    /// - Parameter info: New info object
    public func configure(with info: BugTrackerInfo) {
        self.info = info
        ReportApiFetcher.instance.setAccessToken(info.accessToken)
    }
}
