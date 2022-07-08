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

public struct BugTrackerView: View {
    @Binding var isPresented: Bool

    @State private var projects: [Project] = []
    @State private var reportTypes: [ReportType] = ReportType.allCases
    @State private var report: Report
    @State private var showingImagePicker = false
    @State private var showingDocumentPicker = false
    @State private var showingSuccessMessage = false
    @State private var showingErrorMessage = false
    @State private var result: ReportResult?
    @State private var error: ReportError?

    public init(isPresented: Binding<Bool>) {
        _isPresented = isPresented
        _report = State(initialValue: Report(bucketIdentifier: "",
                                             type: .bugs,
                                             priority: .normal,
                                             subject: "",
                                             description: "",
                                             extra: BugTracker.instance.extra,
                                             files: []))
    }

    public var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("Projet", selection: $report.bucketIdentifier) {
                        ForEach(projects, id: \.identifier) { project in
                            Text(project.title)
                                .tag(project.identifier)
                        }
                    }

                    Picker("Type", selection: $report.type) {
                        ForEach(reportTypes, id: \.rawValue) { type in
                            Text(type.title)
                                .tag(type)
                        }
                    }

                    Picker("Priorité", selection: $report.priority) {
                        ForEach(ReportPriority.allCases, id: \.rawValue) { priority in
                            Text(priority.title)
                                .tag(priority)
                        }
                    }

                    TextField("Sujet", text: $report.subject)

                    TextEditor(text: $report.description)
                        .frame(height: 200)
                }

                Section(header: Text("Fichiers"), footer: Text("Vous pouvez ajouter des fichiers (32 MB maximum) pour aider à mieux comprendre votre bug.")) {
                    ForEach(report.files, id: \.name) { file in
                        FileAttachmentCell(file: file) {
                            remove(file: file)
                        }
                    }

                    Menu {
                        Button {
                            showingImagePicker = true
                        } label: {
                            Label("Depuis la photothèque", systemImage: "photo.on.rectangle")
                        }
                        Button {
                            showingDocumentPicker = true
                        } label: {
                            Label("Depuis Fichiers", systemImage: "folder")
                        }
                    } label: {
                        Label("Ajouter un fichier", systemImage: "paperclip")
                    }
                }
            }
            .navigationTitle("Reporter un bug")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler", action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Soumettre", action: submit)
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(completion: add(file:))
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker(completion: add(file:))
        }
        .alert(result?.state ?? "Success", isPresented: $showingSuccessMessage, presenting: result, actions: { result in
            Button("Open issue") {
                isPresented = false
                guard let url = URL(string: result.url) else { return }
                UIApplication.shared.open(url)
            }
            Button("OK", role: .cancel) {
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
            guard let info = BugTracker.instance.info else { return }
            do {
                let buckets = try await ReportApiFetcher.instance.buckets(route: info.route, project: info.project, serviceId: info.serviceId)
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
        Task {
            do {
                result = try await ReportApiFetcher.instance.send(report: report)
                showingSuccessMessage = true
            } catch let error as ReportError {
                print("[BUG TRACKER] Error while sending report: \(error)")
                self.error = error
                showingErrorMessage = true
            } catch {
                print("[BUG TRACKER] Error while sending report: \(error)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BugTrackerView(isPresented: .constant(true))
    }
}
