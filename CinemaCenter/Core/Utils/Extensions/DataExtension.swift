import Foundation

extension Data {
    var asJSON: [String: Any]? {
        try? JSONSerialization.jsonObject(with: self) as? [String: Any]
    }

    var getMessage: String? {
        if let map = asJSON, let message = map["message"] as? String {
            return message
        }
        return nil
    }

    func decode<T: Decodable>(
        _ type: T.Type,
        strategy: JSONDecoder.KeyDecodingStrategy =
            .convertFromSnakeCase
    ) throws -> T {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = strategy
        return try decoder.decode(T.self, from: self)
    }
}
