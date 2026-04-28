import Foundation

protocol APIServiceProtocol {
    func updateBaseURL(_ baseURL: String)

    func get(
        _ path: String,
        queryParameters: [String: Any]?,
        headers: [String: String]?,
        contentType: String,
        baseURL: String?
    ) async throws -> (Data, URLResponse)

    func post(
        _ path: String,
        data: Any?,
        queryParameters: [String: Any]?,
        headers: [String: String]?,
        contentType: String,
        baseURL: String?
    ) async throws -> (Data, URLResponse)

    func put(
        _ path: String,
        data: Any?,
        queryParameters: [String: Any]?,
        headers: [String: String]?,
        contentType: String,
        baseURL: String?
    ) async throws -> (Data, URLResponse)

    func patch(
        _ path: String,
        data: Any?,
        queryParameters: [String: Any]?,
        headers: [String: String]?,
        contentType: String,
        baseURL: String?
    ) async throws -> (Data, URLResponse)

    func delete(
        _ path: String,
        data: Any?,
        queryParameters: [String: Any]?,
        headers: [String: String]?,
        contentType: String,
        baseURL: String?
    ) async throws -> (Data, URLResponse)
}

class APIService: APIServiceProtocol {
    private let session: URLSession
    private var baseURL: String

    init() {
        self.baseURL = APIEndpoints.tmdbBaseURL
        self.session = URLSession.shared
    }

    func updateBaseURL(_ baseURL: String) {
        self.baseURL = baseURL
    }

    func get(
        _ path: String,
        queryParameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        contentType: String = "application/json",
        baseURL: String? = nil
    ) async throws -> (Data, URLResponse) {
        let request = try buildRequest(
            path: path,
            method: "GET",
            body: nil,
            queryParameters: queryParameters,
            headers: headers,
            contentType: contentType,
            baseURL: baseURL
        )

        return try await session.data(for: request)
    }

    func post(
        _ path: String,
        data: Any? = nil,
        queryParameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        contentType: String = "application/json",
        baseURL: String? = nil
    ) async throws -> (Data, URLResponse) {
        let bodyData = try encodeBody(data)
        let request = try buildRequest(
            path: path,
            method: "POST",
            body: bodyData,
            queryParameters: queryParameters,
            headers: headers,
            contentType: contentType,
            baseURL: baseURL
        )

        return try await session.data(for: request)
    }

    func put(
        _ path: String,
        data: Any? = nil,
        queryParameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        contentType: String = "application/json",
        baseURL: String? = nil
    ) async throws -> (Data, URLResponse) {
        let bodyData = try encodeBody(data)
        let request = try buildRequest(
            path: path,
            method: "PUT",
            body: bodyData,
            queryParameters: queryParameters,
            headers: headers,
            contentType: contentType,
            baseURL: baseURL
        )

        return try await session.data(for: request)
    }

    func patch(
        _ path: String,
        data: Any? = nil,
        queryParameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        contentType: String = "application/json",
        baseURL: String? = nil
    ) async throws -> (Data, URLResponse) {
        let bodyData = try encodeBody(data)
        let request = try buildRequest(
            path: path,
            method: "PATCH",
            body: bodyData,
            queryParameters: queryParameters,
            headers: headers,
            contentType: contentType,
            baseURL: baseURL
        )

        return try await session.data(for: request)
    }

    func delete(
        _ path: String,
        data: Any? = nil,
        queryParameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        contentType: String = "application/json",
        baseURL: String? = nil
    ) async throws -> (Data, URLResponse) {
        let bodyData = try encodeBody(data)
        let request = try buildRequest(
            path: path,
            method: "DELETE",
            body: bodyData,
            queryParameters: queryParameters,
            headers: headers,
            contentType: contentType,
            baseURL: baseURL
        )

        return try await session.data(for: request)
    }

    private func encodeBody(_ data: Any?) throws -> Data? {
        // Return nil if data is nil
        guard let data = data else { return nil }

        // Handle different data types for body encoding
        if let encodableData = data as? any Encodable {
            // Encode Encodable objects to JSON using modern existential opening
            return try JSONEncoder().encode(encodableData)
        } else if let jsonData = data as? [String: Any] {
            // Encode Dictionaries to JSON
            return try JSONSerialization.data(withJSONObject: jsonData)
        } else if let stringData = data as? String {
            // Convert Strings to UTF-8 data
            return stringData.data(using: .utf8)
        } else if let nsData = data as? NSData {
            // Convert NSData to Data
            return nsData as Data
        }

        // Throw error if the data type is not supported
        throw NetworkError.badRequest(
            message: "Bad request, unsupported data type assigned."
        )
    }

    private func buildRequest(
        path: String,
        method: String,
        body: Data?,
        queryParameters: [String: Any]?,
        headers: [String: String]?,
        contentType: String,
        baseURL overriddenBaseURL: String?
    ) throws -> URLRequest {
        // Step 1: Construct the full URL with the base and path
        let finalBaseURL = overriddenBaseURL ?? baseURL
        guard var url = URL(string: finalBaseURL)?.appendingPathComponent(path)
        else {
            throw NetworkError.badRequest(
                message: "Bad request, invalid url provided.",
            )
        }

        // Step 2: Append query parameters to the URL if provided
        if let queryParameters = queryParameters, !queryParameters.isEmpty {
            var components = URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
            )

            // Flatten parameters into URLQueryItems.
            // If a value is an array, it creates multiple items for the same key.
            components?.queryItems = queryParameters.flatMap {
                key,
                value -> [URLQueryItem] in
                if let arrayValue = value as? [Any] {
                    return arrayValue.map {
                        URLQueryItem(name: key, value: "\($0)")
                    }
                }
                return [URLQueryItem(name: key, value: "\(value)")]
            }

            if let finalURL = components?.url {
                url = finalURL
            }
        }

        // Step 3: Initialize the URLRequest with method and body
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body

        // Step 4: Set the default Content-Type and Accept headers
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Step 5: Merge any custom headers provided in the request
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }
}
