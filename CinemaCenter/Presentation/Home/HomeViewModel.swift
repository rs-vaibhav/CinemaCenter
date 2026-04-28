import Foundation
import Observation

@Observable
class HomeViewModel {
    private(set) var status: StateStatus = .initial
    private(set) var videoIdStatus: StateStatus = .initial

    var trendingMovies: [MediaTitle] = []
    var trendingTV: [MediaTitle] = []
    var topRatedMovies: [MediaTitle] = []
    var topRatedTV: [MediaTitle] = []
    var heroTitle = MediaTitle.previewTitles[0]
    var videoId = ""

    private let repository: MediaRepository

    init(repository: MediaRepository = MediaRepositoryImpl()) {
        self.repository = repository
    }

    func getMediaTitles() async {
        status = .loading
        if trendingMovies.isEmpty {
            async let tMoviesState = repository.getTrendingMovies()
            async let tTVState = repository.getTrendingTV()
            async let tRMoviesState = repository.getTopRatedMovies()
            async let tRTVState = repository.getTopRatedTV()

            let (tm, ttv, trm, trttv) = await (
                tMoviesState, tTVState, tRMoviesState, tRTVState
            )

            if case .success(let tmData, _, _) = tm,
                case .success(let ttvData, _, _) = ttv,
                case .success(let trmData, _, _) = trm,
                case .success(let trttvData, _, _) = trttv
            {
                trendingMovies = tmData
                trendingTV = ttvData
                topRatedMovies = trmData
                topRatedTV = trttvData

                if let title = trendingMovies.randomElement() {
                    heroTitle = title
                }
                status = .loaded
            } else {
                // Determine which error to show if needed, for now use a generic error
                status = .error()
            }
        } else {
            status = .loaded
        }
    }

    func getVideoId(for title: String) async {
        videoIdStatus = .loading
        let state = await repository.getMovieVideoId(query: title)
        state.when(
            success: {
                videoId = $0
                videoIdStatus = .loaded
            },
            failure: { _, error in
                videoIdStatus = .error(error: error)
            },
            loading: {
                videoIdStatus = .loading
            }
        )
    }

}
