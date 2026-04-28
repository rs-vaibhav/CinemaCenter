import Foundation

struct APIEndpoints {
    // TMDB Config
    static let tmdbAPIKey = apiConfig.tmdbAPIKey
    static let tmdbBaseURL = "https://api.themoviedb.org"

    // Youtube Config
    static let youtubeAPIKey = apiConfig.youtubeAPIKey
    static let youtubeBaseURL = "https://www.youtube.com/embed"
    static let youtubeSearchURL = "https://www.googleapis.com/youtube/v3/search"

    // Test Data
    static let testMediaTitleURL =
        "https://image.tmdb.org/t/p/w500/nnl6OWkyPpuMm595hmAxNW3rZFn.jpg"
    static let testMediaTitleURL2 =
        "https://image.tmdb.org/t/p/w500/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg"
    static let testMediaTitleURL3 =
        "https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg"

    static let posterURLStart = "https://image.tmdb.org/t/p/w500"

    static func addPosterPath(to titles: inout [MediaTitle]) {
        for index in titles.indices {
            if let path = titles[index].posterPath {
                titles[index].posterPath = APIEndpoints.posterURLStart + path
            }
        }
    }

    private static let apiConfig: APIConfig = {
        do {
            guard
                let url = Bundle.main.url(
                    forResource: "APIConfig",
                    withExtension: "json"
                )
            else {
                print("API configuration file not found.")
                return APIConfig()
            }

            let data = try Data(contentsOf: url)
            return try data.decode(APIConfig.self)
        } catch {
            print("Failed to load API config: \(error.localizedDescription)")
            return APIConfig()
        }
    }()
}
