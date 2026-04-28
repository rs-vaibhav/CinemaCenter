import Foundation

let kCustomerSupport: String = "Please contact our customer support."
let kErrorMessage: String = "Unexpected error occurred. \(kCustomerSupport)"
let kBadRequest: String = "Bad client request. Please try again."
let kTokenExpired: String =
    "Your session has expired. Please try logging in again."
let kBadResponse: String = "Bad server response. \(kCustomerSupport)"
let kServerError: String = "Internal server error. \(kCustomerSupport)"
let kConnectionFailure: String = "Please check your internet and try again."
let kNoConnection: String =
    "No internet connection. Please check your internet and try again."

enum NetworkError: Error, LocalizedError {
    case badRequest(message: String? = nil)
    case tokenExpired
    case badResponse(message: String? = nil)
    case serverError(message: String? = nil)
    case connectionFailure
    case noConnection

    var errorDescription: String? {
        switch self {
        case .badRequest(let message):
            return message ?? kBadRequest
        case .tokenExpired:
            return kTokenExpired
        case .badResponse(let message):
            return message ?? kBadResponse
        case .serverError(let message):
            return message ?? kServerError
        case .connectionFailure:
            return kConnectionFailure
        case .noConnection:
            return kNoConnection
        }
    }
}
