import Foundation

enum DataState<T> {
    case loading
    case success(data: T, message: String? = nil, statusCode: Int? = nil)
    case failure(
        error: Error,
        message: String = kErrorMessage,
        statusCode: Int? = nil
    )

    /// Decomposes the state into its constituent parts.
    func when<R>(
        success: (T) -> R,
        failure: (String, Error) -> R,
        loading: () -> R
    ) -> R {
        switch self {
        case .loading:
            return loading()
        case .success(let data, _, _):
            return success(data)
        case .failure(let error, let message, _):
            return failure(message, error)
        }
    }

    /// Provides all available metadata for each state.
    func map<R>(
        success: (T, String?, Int?) -> R,
        failure: (Error, String, Int?) -> R,
        loading: () -> R
    ) -> R {
        switch self {
        case .loading:
            return loading()
        case .success(let data, let message, let statusCode):
            return success(data, message, statusCode)
        case .failure(let error, let message, let statusCode):
            return failure(error, message, statusCode)
        }
    }

    /// Transforms the success data while preserving other metadata.
    func mapData<R>(_ transform: (T) -> R) -> DataState<R> {
        switch self {
        case .loading:
            return .loading
        case .success(let data, let message, let statusCode):
            return .success(
                data: transform(data),
                message: message,
                statusCode: statusCode
            )
        case .failure(let error, let message, let statusCode):
            return .failure(
                error: error,
                message: message,
                statusCode: statusCode
            )
        }
    }
}
