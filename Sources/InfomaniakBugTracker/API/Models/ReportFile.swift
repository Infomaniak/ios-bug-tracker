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

import SwiftUI
import UniformTypeIdentifiers

struct ReportFile: Encodable, Equatable {
    let name: String
    let data: Data
    let uti: UTType

    var systemIconName: String {
        if uti.conforms(to: .image) {
            return "photo"
        } else if uti.conforms(to: .video) {
            return "play.rectangle"
        } else if uti.conforms(to: .plainText) {
            return "doc.text"
        } else if uti.conforms(to: .rtf) || uti.conforms(to: .rtfd) {
            return "doc.richtext"
        } else if uti.conforms(to: .archive) {
            return "doc.zipper"
        } else {
            return "doc"
        }
    }
}
