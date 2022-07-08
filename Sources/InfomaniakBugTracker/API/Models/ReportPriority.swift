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

enum ReportPriority: Int, CaseIterable, Encodable {
    case low = 1
    case normal
    case high
    case urgent
    case immediate

    var title: String {
        switch self {
        case .low:
            return Translation.priorityLow
        case .normal:
            return Translation.priorityNormal
        case .high:
            return Translation.priorityHigh
        case .urgent:
            return Translation.priorityUrgent
        case .immediate:
            return Translation.priorityImmediate
        }
    }
}
