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

struct Buckets: Decodable {
    let current: PartialProject?
    let list: [Project]

    private enum CodingKeys: String, CodingKey {
        case current, list
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        current = try values.decodeIfPresent(PartialProject.self, forKey: .current)
        let dictionary = try values.decode([String: PartialProject].self, forKey: .list)
        list = dictionary.map { Project(identifier: $0, partialProject: $1) }
    }
}
