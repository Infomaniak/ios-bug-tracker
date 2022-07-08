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

class ReportApiFetcher {
    enum HTTPMethod: String {
        case get = "GET", post = "POST"
    }

    static let instance = ReportApiFetcher()

    private let apiEndpoint = "https://welcome.infomaniak.com"
    private lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    private let formEncoder = URLEncodedFormEncoder(boolEncoding: .literal)

    private var accessToken: String = ""

    // MARK: - Private methods

    private init() {}

    private func makeRequest<T: Decodable>(method: HTTPMethod = .get, path: String, contentType: String? = nil, body: Data? = nil) async throws -> T {
        guard let url = URL(string: apiEndpoint + path) else {
            throw ReportError.invalidURL
        }
        var request = URLRequest(url: url)
        if let contentType = contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpMethod = method.rawValue
        request.httpBody = body

        if method != .get {
            // XSRF cookie needs to be passed in request header
            let cookies = HTTPCookieStorage.shared.cookies(for: url)
            if let xsrfCookie = cookies?.first(where: { $0.name == "SHOP-XSRF-TOKEN" }) {
                request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }
        }

        let (data, response) = try await URLSession.shared.data(for: request)
        let json = try jsonDecoder.decode(ApiResponse<T>.self, from: data)
        if let data = json.data {
            return data
        } else if let error = json.error {
            throw ReportError.apiError(error)
        } else {
            throw ReportError.httpError(status: (response as? HTTPURLResponse)?.statusCode ?? -1)
        }
    }

    private func multipartFormEncode(_ value: Encodable) throws -> (String, Data) {
        let component: URLEncodedFormComponent = try formEncoder.encode(value)

        guard case let .object(object) = component else {
            throw URLEncodedFormEncoder.Error.invalidRootObject("\(component)")
        }

        let serializer = MultipartFormDataSerializer(alphabetizeKeyValuePairs: false,
                                                     arrayEncoding: .brackets,
                                                     keyEncoding: .useDefaultKeys,
                                                     spaceEncoding: .percentEscaped,
                                                     allowedCharacters: .afURLQueryAllowed)

        return (serializer.contentType, serializer.serialize(object))
    }

    // MARK: - Public methods

    func setAccessToken(_ accessToken: String) {
        self.accessToken = accessToken
    }

    func buckets(route: String? = nil, project: String, serviceId: Int? = nil) async throws -> Buckets {
        try await makeRequest(path: "/api/components/report?route=\(route ?? "null")&project=\(project)&service=\(serviceId ?? 0)")
    }

    func send(report: Report) async throws -> ReportResult {
        let contentType: String?
        let body: Data?
        if report.files.isEmpty {
            // URL encoded form
            contentType = nil
            body = try formEncoder.encode(report)
        } else {
            // Multipart form data
            (contentType, body) = try multipartFormEncode(report)
        }
        return try await makeRequest(method: .post, path: "/api/components/report", contentType: contentType, body: body)
    }
}
