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

enum ReportError: LocalizedError {
    case invalidURL
    case httpError(status: Int)
    case apiError(ApiError)
    case cannotConvertImageToData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return Translation.errorInvalidURL
        case .httpError(let statusCode):
            return Translation.errorHTTP(code: statusCode)
        case .apiError:
            return Translation.errorAPI
        case .cannotConvertImageToData:
            return Translation.errorCannotConvertImageToData
        }
    }

    var details: String {
        switch self {
        case .apiError(let apiError):
            return apiError.description
        default:
            return Translation.errorGenericDetail
        }
    }
}
