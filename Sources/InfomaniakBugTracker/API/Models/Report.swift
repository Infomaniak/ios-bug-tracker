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

struct Report: Encodable {
    var bucketIdentifier: String
    var type: ReportType
    var priority: ReportPriority
    var subject: String
    var description: String
    var extra: ReportExtra

    private enum CodingKeys: String, CodingKey {
        case bucketIdentifier, type, priority, subject, description, extra
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(bucketIdentifier, forKey: .bucketIdentifier)
        try container.encode(type, forKey: .type)
        try container.encode(["value": "\(priority.rawValue)", "label": "Priorité: \(priority.title)"], forKey: .priority)
        try container.encode(subject, forKey: .subject)
        try container.encode(description, forKey: .description)
        try container.encode(extra, forKey: .extra)
    }
}
