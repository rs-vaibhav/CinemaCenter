import Foundation

class MediaRepositoryImpl: MediaRepository {
    private let dataSource: MediaRemoteDataSourceProtocol

    init(dataSource: MediaRemoteDataSourceProtocol = MediaRemoteDataSource()) {
        self.dataSource = dataSource
    }

    func getTrendingMovies() async -> DataState<[MediaTitle]> {
        return await dataSource.fetchTitles(
            for: "movie",
            by: "trending",
            searchPhrase: nil
        )
    }

    func getTrendingTV() async -> DataState<[MediaTitle]> {
        return await dataSource.fetchTitles(
            for: "tv",
            by: "trending",
            searchPhrase: nil
        )
    }

    func getTopRatedMovies() async -> DataState<[MediaTitle]> {
        return await dataSource.fetchTitles(
            for: "movie",
            by: "top_rated",
            searchPhrase: nil
        )
    }

    func getTopRatedTV() async -> DataState<[MediaTitle]> {
        return await dataSource.fetchTitles(
            for: "tv",
            by: "top_rated",
            searchPhrase: nil
        )
    }

    func getUpcomingMovies() async -> DataState<[MediaTitle]> {
        return await dataSource.fetchTitles(
            for: "movie",
            by: "upcoming",
            searchPhrase: nil
        )
    }

    func search(query: String, media: String) async -> DataState<[MediaTitle]> {
        return await dataSource.fetchTitles(
            for: media,
            by: "search",
            searchPhrase: query
        )
    }

    func getMovieVideoId(query: String) async -> DataState<String> {
        return await dataSource.fetchVideoId(for: query)
    }
}
