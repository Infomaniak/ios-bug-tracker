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

import Combine
import SwiftUI
import UIKit

class BugTrackerViewModel: ObservableObject {
    @Published var isPresented = true
}

/// Main Bug Tracker view controller.
public class BugTrackerViewController: UIViewController {
    @ObservedObject var viewModel = BugTrackerViewModel()
    var files: [ReportFile]

    private var cancellable: AnyCancellable?

    /// Creates a Bug Tracker view controller.
    /// - Parameters:
    ///   - files: Array of files to add to the report by default.
    public init(files: [ReportFile] = []) {
        self.files = files
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        // Create view
        let bugTrackerView = BugTrackerView(isPresented: $viewModel.isPresented, files: files)
        let hostingController = UIHostingController(rootView: bugTrackerView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        // Observe changes
        cancellable = viewModel.$isPresented.sink { isPresented in
            if !isPresented {
                self.dismiss(animated: true)
            }
        }
    }
}
