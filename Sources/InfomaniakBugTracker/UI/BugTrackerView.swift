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

    private let info = BugTracker.instance.info

    public init(isPresented: Binding<Bool>) {
        _isPresented = isPresented
        let extra: ReportExtra
        if let info = info {
            extra = ReportExtra(project: info.project, route: info.route ?? "null", userAgent: "")
        } else {
            extra = ReportExtra(project: "", route: "", userAgent: "")
        }
        _report = State(initialValue: Report(bucketIdentifier: "",
                                             type: .bugs,
                                             priority: .normal,
                                             subject: "",
                                             description: "",
                                             extra: extra))
    }

    public var body: some View {
        NavigationView {
            Form {
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

                TextField("", text: $report.subject, prompt: Text("Sujet"))

                TextEditor(text: $report.description)
                    .frame(height: 200)
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
        .task {
            guard let info = info else { return }
            do {
                let buckets = try await ReportApiFetcher.instance.buckets(route: info.route, project: info.project, serviceId: info.serviceId)
                projects = buckets.list
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

    private func cancel() {
        isPresented = false
    }

    private func submit() {
        Task {
            do {
                _ = try await ReportApiFetcher.instance.send(report: report)
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
