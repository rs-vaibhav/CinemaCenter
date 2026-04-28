import Foundation
import os.log

class ErrorHandler {
    private init() {}  // Private constructor

    /// Run an asynchronous callback and log any exceptions (no rethrow).
    static func executeSafe(_ callBack: () async throws -> Void) async {
        do {
            try await callBack()
        } catch {
            debugError(error)
        }
    }

    /// Run an async callback that returns `T`, logging exceptions.
    /// On error this returns the provided `valueOnError` fallback.
    static func executeSafeReturn<T>(
        _ callBack: () async throws -> T,
        valueOnError: T
    ) async -> T {
        do {
            return try await callBack()
        } catch {
            debugError(error)
            return valueOnError
        }
    }

    /// Run a synchronous callback and log any exceptions (no rethrow).
    static func executeSafeSync(_ callBack: () throws -> Void) {
        do {
            try callBack()
        } catch {
            debugError(error)
        }
    }

    /// Run a synchronous callback that returns `T`, logging exceptions.
    /// On error this returns the provided `valueOnError` fallback.
    static func executeSafeReturnSync<T>(
        _ callBack: () throws -> T,
        valueOnError: T
    ) -> T {
        do {
            return try callBack()
        } catch {
            debugError(error)
            return valueOnError
        }
    }

    /// Execute a callback that returns a `DataState<T>` and convert
    /// thrown exceptions into appropriate `FailureState<T>` instances.
    static func execute<T>(
        _ callBack: () async throws -> DataState<T>
    ) async -> DataState<T> {
        do {
            return try await callBack()
        } catch let error as URLError {
            debugError("URL Error: \(error.localizedDescription)")
            debugError(error)
            return _urlErrorToFailureState(error)
        } catch {
            debugError(error)
            return .failure(error: error, message: error.localizedDescription)
        }
    }

    /// Returns the respective data failure state based on the URL error.
    private static func _urlErrorToFailureState<T>(_ error: URLError)
        -> DataState<T>
    {
        let errorMessage = urlErrorMessages[error.code] ?? kErrorMessage

        return .failure(
            error: error,
            message: errorMessage,
            statusCode: error.errorCode
        )
    }

    private static func debugError(_ error: Any?, _ stackTrace: String? = nil) {
        #if DEBUG
            if let error = error {
                os_log("❌ Error: %@", type: .error, String(describing: error))
                if let stackTrace = stackTrace {
                    os_log("📋 StackTrace: %@", type: .error, stackTrace)
                }
            }
        #endif
    }

    private static let urlErrorMessages: [URLError.Code: String] = [
        .badURL: "The URL was invalid.",
        .timedOut: "The request timed out. \(kConnectionFailure)",
        .cannotFindHost: "Cannot find the host. \(kConnectionFailure)",
        .cannotConnectToHost:
            "Cannot connect to the host. \(kConnectionFailure)",
        .networkConnectionLost:
            "Network connection was lost. \(kConnectionFailure)",
        .dnsLookupFailed: "DNS lookup failed. \(kConnectionFailure)",
        .httpTooManyRedirects: "Too many redirects occurred.",
        .resourceUnavailable: "The requested resource is unavailable.",
        .notConnectedToInternet:
            "Not connected to the internet. \(kConnectionFailure)",
        .redirectToNonExistentLocation:
            "Redirected to a non-existent location.",
        .badServerResponse: "The server returned an invalid response.",
        .userCancelledAuthentication:
            "Authentication was cancelled by the user.",
        .userAuthenticationRequired: "Authentication is required.",
        .noPermissionsToReadFile: "No permissions to read the file.",
        .secureConnectionFailed:
            "Secure connection failed. \(kCustomerSupport)",
        .serverCertificateHasBadDate:
            "Server certificate has an invalid date. \(kCustomerSupport)",
        .serverCertificateUntrusted:
            "Server certificate is not trusted. \(kCustomerSupport)",
        .serverCertificateHasUnknownRoot:
            "Server certificate has an unknown root. \(kCustomerSupport)",
        .serverCertificateNotYetValid:
            "Server certificate is not yet valid. \(kCustomerSupport)",
        .clientCertificateRejected:
            "Client certificate was rejected. \(kCustomerSupport)",
        .clientCertificateRequired:
            "Client certificate is required. \(kCustomerSupport)",
        .cannotLoadFromNetwork:
            "Cannot load from network. \(kConnectionFailure)",
        .dataNotAllowed: "Data network not allowed. \(kConnectionFailure)",
        .internationalRoamingOff:
            "International roaming is off. \(kConnectionFailure)",
        .callIsActive: "Call is active. Please try again later.",
        .dataLengthExceedsMaximum: "Data length exceeds maximum limit.",
        .unknown: kErrorMessage,
    ]

    private static let firebaseAuthErrorMessages: [String: String] = [
        "invalid-credential": "The given user was not found on the server!",
        "user-not-found": "The given user was not found on the server!",
        "wrong-password":
            "The password is invalid or the user does not have a password.",
        "weak-password":
            "Please choose a stronger password consisting of more characters!",
        "invalid-email":
            "Invalid email. Please double check your email and try again!",
        "operation-not-allowed":
            "You cannot register using this method at this moment!",
        "email-already-in-use":
            "Email already in use. Please choose another email to register with!",
        "requires-recent-login":
            "You need to log out and log back in again in order to perform this operation",
        "no-current-user": "No current user with this information was found",
        "user-disabled": "This user account has been disabled.",
        "too-many-requests": "Too many requests. Try again later.",
        "account-exists-with-different-credential":
            "An account already exists with a different credential.",
        "invalid-verification-code":
            "The verification code is invalid or expired.",
        "invalid-verification-id": "The verification ID is invalid.",
        "network-request-failed":
            "Network error. Please check your internet connection and try again!",
        "unknown": "Unknown authentication error",
    ]

    private static let googleSignInErrorMessages: [String: String] = [
        "unknownError":
            "An unknown error occurred during Google Sign-In. Please try again.",
        "canceled":
            "The sign-in process was canceled. Please try again if you want to sign in.",
        "interrupted": "The sign-in process was interrupted. Please try again.",
        "clientConfigurationError":
            "Google Sign-In is not configured correctly on this app. Please contact support.",
        "providerConfigurationError":
            "There is a problem with the Google Sign-In provider configuration. Please contact support.",
        "uiUnavailable":
            "The sign-in UI could not be displayed. This might be a temporary issue, please try again.",
        "userMismatch":
            "The user trying to sign in is different from the one already signed in. Please sign out first.",
    ]
}
