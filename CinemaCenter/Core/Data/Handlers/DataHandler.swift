import Foundation

// DataHandler centralizes API response handling and error mapping into DataState
class DataHandler {
    private init() {}

    static func safeApiCall<T: Decodable>(
        request: @escaping () async throws -> (Data, URLResponse),
        validStatusCodes: Set<Int> = Set(200...299),
        isStandardResponse: Bool = true,
        responseDataKey: String = "data",
        decodingStrategy: JSONDecoder.KeyDecodingStrategy =
            .convertFromSnakeCase,
        staticData: Any? = nil
    ) async -> DataState<T> {
        await ErrorHandler.execute {
            let (data, response) = try await request()
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            let message = data.getMessage

            // 1. Validate Status Code
            if !validStatusCodes.contains(statusCode) {
                let error: NetworkError
                switch statusCode {
                case 400...499: error = .badRequest(message: message)
                case 500...599: error = .serverError(message: message)
                default: error = .badResponse(message: message)
                }

                return .failure(
                    error: error,
                    message: error.localizedDescription,
                    statusCode: statusCode
                )
            }

            // 2. Handle Static Data
            if let staticData = staticData as? T {
                return .success(
                    data: staticData,
                    message: message,
                    statusCode: statusCode
                )
            }

            // 3. Extract and Decode Data
            do {
                var rawData: Any = try JSONSerialization.jsonObject(with: data)

                // 3.1. Extract nested data if required
                if isStandardResponse {
                    guard let map = rawData as? [String: Any],
                        let nested = map[responseDataKey]
                    else {
                        return .failure(
                            error: NetworkError.badResponse(
                                message:
                                    "Missing key '\(responseDataKey)' in response"
                            ),
                            message: kBadResponse,
                            statusCode: statusCode
                        )
                    }
                    rawData = nested
                }

                // 3.2. Return immediately if types match (e.g. T is a simple type already parsed)
                if let directMatchedData = rawData as? T {
                    return .success(
                        data: directMatchedData,
                        message: message,
                        statusCode: statusCode
                    )
                }

                // 3.3. Otherwise, convert back to Data for JSONDecoder (for Structs/Classes)
                let jsonData = try JSONSerialization.data(
                    withJSONObject: rawData
                )
                let decodedData = try jsonData.decode(
                    T.self,
                    strategy: decodingStrategy
                )

                return .success(
                    data: decodedData,
                    message: message,
                    statusCode: statusCode
                )
            } catch {
                return .failure(
                    error: NetworkError.badResponse(
                        message:
                            "Processing failed: \(error.localizedDescription)"
                    ),
                    message: kBadResponse,
                    statusCode: statusCode
                )
            }
        }
    }
}
