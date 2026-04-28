import Foundation

protocol MediaRepository {
    func getTrendingMovies() async -> DataState<[MediaTitle]>
    func getTrendingTV() async -> DataState<[MediaTitle]>
    func getTopRatedMovies() async -> DataState<[MediaTitle]>
    func getTopRatedTV() async -> DataState<[MediaTitle]>
    func getUpcomingMovies() async -> DataState<[MediaTitle]>
    func search(query: String, media: String) async -> DataState<[MediaTitle]>
    func getMovieVideoId(query: String) async -> DataState<String>
}
