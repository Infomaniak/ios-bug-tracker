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

import OSLog
import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    let completion: (ReportFile) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.selectionLimit = 0
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            let itemProviders = results.map(\.itemProvider)

            for itemProvider in itemProviders where itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    guard let image = image as? UIImage else {
                        if let error = error {
                            Logger.general.error("Error while accessing file: \(error)")
                        } else {
                            Logger.general.error("Image is nil")
                        }
                        return
                    }
                    do {
                        let file = try ReportFile.from(image: image, named: itemProvider.suggestedName ?? "No name")
                        DispatchQueue.main.async {
                            self.parent.completion(file)
                        }
                    } catch {
                        Logger.general.error("Error while accessing image: \(error)")
                    }
                }
            }
        }
    }
}
