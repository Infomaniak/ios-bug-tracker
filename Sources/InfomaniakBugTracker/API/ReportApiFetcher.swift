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

import Alamofire
import Foundation
import InfomaniakCore

extension ApiEnvironment {
    var welcomeHost: String {
        return "welcome.\(host)"
    }
}

extension Endpoint {
    static var report: Endpoint {
        return Endpoint(hostKeypath: \.welcomeHost, path: "/api/web-components/1/report")
    }

    static func buckets(route: String? = nil, project: String, serviceId: Int? = nil) -> Endpoint {
        return .report.appending(path: "",
                                 queryItems: [URLQueryItem(name: "route", value: "\(route ?? "null")"),
                                              URLQueryItem(name: "project", value: "\(project)"),
                                              URLQueryItem(name: "service", value: "\(serviceId ?? 0)")])
    }
}

extension ApiFetcher {
    var reportDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }

    func buckets(route: String? = nil, project: String, serviceId: Int? = nil) async throws -> Buckets {
        try await perform(request: authenticatedRequest(.buckets(route: route, project: project, serviceId: serviceId)),
                          overrideDecoder: reportDecoder)
    }

    func send(report: Report) async throws -> ReportResult {
        let formEncoder = URLEncodedFormEncoder(boolEncoding: .literal)
        let contentType: String?
        let body: Data?

        if report.files.isEmpty {
            // URL encoded form
            contentType = nil
            body = try formEncoder.encode(report)
        } else {
            // Multipart form data
            (contentType, body) = try multipartFormEncode(report, formEncoder: formEncoder)
        }

        var request = try URLRequest(url: Endpoint.report.url, method: .post)
        if let contentType = contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        guard let body else { throw ReportError.invalidURL }
        return try await perform(request: authenticatedSession.upload(body, with: request), overrideDecoder: reportDecoder)
    }

    private func multipartFormEncode(_ value: Encodable, formEncoder: URLEncodedFormEncoder) throws -> (String, Data) {
        let component: URLEncodedFormComponent = try formEncoder.encode(value)

        guard case .object(let object) = component else {
            throw URLEncodedFormEncoder.Error.invalidRootObject("\(component)")
        }

        let serializer = MultipartFormDataSerializer(alphabetizeKeyValuePairs: false,
                                                     arrayEncoding: .brackets,
                                                     keyEncoding: .useDefaultKeys,
                                                     spaceEncoding: .percentEscaped,
                                                     allowedCharacters: .afURLQueryAllowed)

        return (serializer.contentType, serializer.serialize(object))
    }
}
