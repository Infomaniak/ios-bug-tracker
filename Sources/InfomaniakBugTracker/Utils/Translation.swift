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

struct Translation {
    static let titleReportBug = localizedString(key: "titleReportBug")
    static let fieldProject = localizedString(key: "fieldProject")
    static let fieldType = localizedString(key: "fieldType")
    static let fieldPriority = localizedString(key: "fieldPriority")
    static let fieldSubject = localizedString(key: "fieldSubject")
    static let fieldDescription = localizedString(key: "fieldDescription")
    static let sectionFilesHeader = localizedString(key: "sectionFilesHeader")
    static let sectionsFilesFooter = localizedString(key: "sectionsFilesFooter")
    static let buttonAddFile = localizedString(key: "buttonAddFile")
    static let buttonAddFromPhotoLibrary = localizedString(key: "buttonAddFromPhotoLibrary")
    static let buttonAddFromFiles = localizedString(key: "buttonAddFromFiles")
    static let buttonCancel = localizedString(key: "buttonCancel")
    static let buttonSubmit = localizedString(key: "buttonSubmit")
    static let alertTitleSuccess = localizedString(key: "alertTitleSuccess")
    static let buttonOpenIssue = localizedString(key: "buttonOpenIssue")
    static let buttonOK = localizedString(key: "buttonOK")
    static let issueSuccessfullyCreated = localizedString(key: "Issue successfully created")
    static let errorInvalidURL = localizedString(key: "errorInvalidURL")
    static let outdatedVersion = localizedString(key: "outdatedVersion")

    static func errorHTTP(code: Int) -> String {
        localizedString(key: "errorHTTP", code)
    }

    static let errorAPI = localizedString(key: "errorAPI")
    static let errorCannotConvertImageToData = localizedString(key: "errorCannotConvertImageToData")
    static let errorGenericDetail = localizedString(key: "errorGenericDetail")
    static let priorityLow = localizedString(key: "priorityLow")
    static let priorityNormal = localizedString(key: "priorityNormal")
    static let priorityHigh = localizedString(key: "priorityHigh")
    static let priorityUrgent = localizedString(key: "priorityUrgent")
    static let priorityImmediate = localizedString(key: "priorityImmediate")
    static let typeBug = localizedString(key: "typeBug")
    static let typeFeature = localizedString(key: "typeFeature")
    static let alertReportScreenshotTitle = localizedString(key: "alertReportScreenshotTitle")
    static let buttonYes = localizedString(key: "buttonYes")
    static let buttonNo = localizedString(key: "buttonNo")

    private static func localizedString(key: String, _ arguments: CVarArg...) -> String {
        return String(format: NSLocalizedString(key, bundle: .module, comment: ""), arguments: arguments)
    }
}
