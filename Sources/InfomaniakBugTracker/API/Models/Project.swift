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

struct ProjectAction: Decodable {
    // TODO: Add properties
}

struct PartialProject: Decodable {
    let enabled: Bool
    let title: String
    let projects: [String]?
    // let routeSlugs: [String: [String]]?
    let servicesId: [Int]?
    let actions: [String: ProjectAction]
}

struct Project: Decodable {
    let identifier: String
    let enabled: Bool
    let title: String
    let projects: [String]?
    // let routeSlugs: [String: [String]]?
    let servicesId: [Int]?
    let actions: [String: ProjectAction]

    var allowedReportTypes: [ReportType] {
        return actions.keys.compactMap { ReportType(rawValue: $0) }.sorted(by: { $0.rawValue < $1.rawValue })
    }

    init(identifier: String, enabled: Bool, title: String, projects: [String]?, servicesId: [Int]? /* , routeSlugs: [String: [String]]? */, actions: [String: ProjectAction]) {
        self.identifier = identifier
        self.enabled = enabled
        self.title = title
        self.projects = projects
        // self.routeSlugs = routeSlugs
        self.servicesId = servicesId
        self.actions = actions
    }

    init(identifier: String, partialProject: PartialProject) {
        self.init(identifier: identifier,
                  enabled: partialProject.enabled,
                  title: partialProject.title,
                  projects: partialProject.projects /* ,
                   routeSlugs: partialProject.routeSlugs */,
                  servicesId: partialProject.servicesId,
                  actions: partialProject.actions)
    }
}
