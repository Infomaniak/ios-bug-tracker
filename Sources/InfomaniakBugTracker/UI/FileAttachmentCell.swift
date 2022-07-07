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

struct FileAttachmentCell: View {
    let file: ReportFile
    let action: () -> Void

    var body: some View {
        HStack {
            Label("\(file.name) (\(Int64(file.data.count), format: ByteCountFormatStyle.byteCount(style: .file)))", systemImage: file.systemIconName)
            Spacer()
            Button(role: .destructive, action: action) {
                Label("Supprimer", systemImage: "trash")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.borderless)
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        FileAttachmentCell(file: ReportFile(name: "", data: Data(), uti: .data)) { /* Preview */ }
    }
}
