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

import InfomaniakDI
import SwiftUI

/// Main Bug Tracker view.
public struct BugTrackerView: View {
    @LazyInjectService var bugTracker: BugTracker

    @Binding var isPresented: Bool

    @State private var projects: [Project] = []
    @State private var reportTypes: [ReportType] = ReportType.allCases
    @State private var report: Report
    @State private var showingImagePicker = false
    @State private var showingDocumentPicker = false
    @State private var showingSuccessMessage = false
    @State private var showingErrorMessage = false
    @State private var isLoading = false
    @State private var result: ReportResult?
    @State private var error: ReportError?

    /// Creates a Bug Tracker view.
    /// - Parameters:
    ///   - isPresented: Binding to the boolean presenting the view.
    ///   - files: Array of files to add to the report by default.
    public init(isPresented: Binding<Bool>, files: [ReportFile] = []) {
        // Bug tracker is needed here because we don't have self yet
        @InjectService var bugTracker: BugTracker
        _isPresented = isPresented
        _report = State(initialValue: Report(bucketIdentifier: "",
                                             type: .bugs,
                                             priority: .normal,
                                             subject: "",
                                             description: "",
                                             extra: bugTracker.extra,
                                             files: files))
        UIScrollView.appearance().keyboardDismissMode = .onDrag
    }

    public var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(Translation.fieldProject, selection: $report.bucketIdentifier) {
                        ForEach(projects, id: \.identifier) { project in
                            Text(project.title)
                                .tag(project.identifier)
                        }
                    }

                    Picker(Translation.fieldType, selection: $report.type) {
                        ForEach(reportTypes, id: \.rawValue) { type in
                            Text(type.title)
                                .tag(type)
                        }
                    }

                    Picker(Translation.fieldPriority, selection: $report.priority) {
                        ForEach(ReportPriority.allCases, id: \.rawValue) { priority in
                            Text(priority.title)
                                .tag(priority)
                        }
                    }

                    TextField(Translation.fieldSubject, text: $report.subject)

                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $report.description)
                            .frame(height: 200)
                            .padding(.horizontal, -5)
                        if report.description.isEmpty {
                            Text(Translation.fieldDescription)
                                .foregroundColor(Color(uiColor: .tertiaryLabel))
                                .padding(.top, 8)
                        }
                    }
                }

                Section(header: Text("sectionFilesHeader", bundle: .module), footer: Text("sectionsFilesFooter", bundle: .module)) {
                    ForEach(report.files, id: \.name) { file in
                        FileAttachmentCell(file: file) {
                            remove(file: file)
                        }
                    }

                    Menu {
                        Button {
                            showingImagePicker = true
                        } label: {
                            Label(Translation.buttonAddFromPhotoLibrary, systemImage: "photo.on.rectangle")
                        }
                        Button {
                            showingDocumentPicker = true
                        } label: {
                            Label(Translation.buttonAddFromFiles, systemImage: "folder")
                        }
                    } label: {
                        Label(Translation.buttonAddFile, systemImage: "paperclip")
                    }
                }
            }
            .navigationTitle(Translation.titleReportBug)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Translation.buttonCancel, action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button(Translation.buttonSubmit, action: submit)
                    }
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(completion: add(file:))
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker(completion: add(file:))
        }
        .alert(result?.localizedState ?? Translation.alertTitleSuccess, isPresented: $showingSuccessMessage, presenting: result, actions: { result in
            Button(Translation.buttonOpenIssue) {
                isPresented = false
                guard let url = URL(string: result.url) else { return }
                UIApplication.shared.open(url)
            }
            Button(Translation.buttonOK, role: .cancel) {
                isPresented = false
            }
        }, message: { result in
            Text("URL: \(result.url)")
        })
        .alert(isPresented: $showingErrorMessage, error: error, actions: { _ in
            // Default button
        }, message: { error in
            Text(error.details)
        })
        .task {
            let info = bugTracker.info
            do {
                let buckets = try await bugTracker.buckets(route: info.route, project: info.project, serviceId: info.serviceId)
                projects = buckets.list.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
                guard let currentProject = buckets.list.first(where: { $0.title.caseInsensitiveCompare(buckets.current?.title ?? "") == .orderedSame }) else { return }
                report.bucketIdentifier = currentProject.identifier
                if let firstType = currentProject.allowedReportTypes.first {
                    report.type = firstType
                }
                reportTypes = currentProject.allowedReportTypes
            } catch {
                print("[BUG TRACKER] Error while fetching buckets: \(error)")
            }
        }
    }

    private func add(file: ReportFile) {
        withAnimation {
            report.files.append(file)
        }
    }

    private func remove(file: ReportFile) {
        guard let index = report.files.firstIndex(of: file) else { return }
        _ = withAnimation {
            report.files.remove(at: index)
        }
    }

    private func cancel() {
        isPresented = false
    }

    private func submit() {
        isLoading = true
        Task {
            do {
                result = try await bugTracker.send(report: report)
                showingSuccessMessage = true
            } catch let error as ReportError {
                print("[BUG TRACKER] Error while sending report: \(error)")
                self.error = error
                showingErrorMessage = true
            } catch {
                print("[BUG TRACKER] Error while sending report: \(error)")
            }
            isLoading = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BugTrackerView(isPresented: .constant(true))
    }
}
