import Foundation

/// The status of a bloc/state when there is only a single state.
/// * initial - The initial state.
/// * loading - The state when data loading is in progress.
/// * loaded - The state when data loads without any issue.
/// * error - The state when there is an error while loading the data.
/// * noInternet - The state when there is no internet connection.
enum StateStatus {
    case initial, loading, loaded
    case error(error: Error? = nil)
    case noInternet

    /// Decomposes the status into its constituent parts.
    func when<R>(
        initial: () -> R,
        loading: () -> R,
        loaded: () -> R,
        onError: (Error?) -> R,
        noInternet: () -> R
    ) -> R {
        switch self {
        case .initial:
            return initial()
        case .loading:
            return loading()
        case .loaded:
            return loaded()
        case .error(let error):
            return onError(error)
        case .noInternet:
            return noInternet()
        }
    }

    /// Maps the status to a result type.
    func map<R>(
        initial: () -> R,
        loading: () -> R,
        loaded: () -> R,
        onError: (Error?) -> R,
        noInternet: () -> R
    ) -> R {
        switch self {
        case .initial:
            return initial()
        case .loading:
            return loading()
        case .loaded:
            return loaded()
        case .error(let error):
            return onError(error)
        case .noInternet:
            return noInternet()
        }
    }
}
