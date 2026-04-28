import Foundation

protocol MediaRemoteDataSourceProtocol {
    func fetchTitles(for media: String, by type: String, searchPhrase: String?)
        async -> DataState<[MediaTitle]>
    func fetchVideoId(for title: String) async -> DataState<String>
}

class MediaRemoteDataSource: MediaRemoteDataSourceProtocol {
    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }

    func fetchTitles(
        for media: String,
        by type: String,
        searchPhrase: String? = nil
    ) async -> DataState<[MediaTitle]> {
        let path = buildTMDBPath(media: media, type: type)
        var parameters: [String: Any] = ["api_key": APIEndpoints.tmdbAPIKey]
        if let searchPhrase {
            parameters["query"] = searchPhrase
        }

        let result: DataState<[MediaTitle]> = await DataHandler.safeApiCall(
            request: {
                try await self.apiService.get(
                    path,
                    queryParameters: parameters,
                    headers: nil,
                    contentType: "application/json",
                    baseURL: nil
                )
            },
            responseDataKey: "results",
            decodingStrategy: .convertFromSnakeCase
        )

        return result.mapData { titles in
            var updatedTitles = titles
            APIEndpoints.addPosterPath(to: &updatedTitles)
            return updatedTitles
        }
    }

    func fetchVideoId(for title: String) async -> DataState<String> {
        let trailerSearch = title + " trailer"
        let parameters: [String: Any] = [
            "q": trailerSearch,
            "part": "snippet",
            "type": "video",
            "key": APIEndpoints.youtubeAPIKey,
        ]

        let result: DataState<YoutubeSearchResponse> = await DataHandler.safeApiCall(
            request: {
                try await self.apiService.get(
                    "",
                    queryParameters: parameters,
                    headers: nil,
                    contentType: "application/json",
                    baseURL: APIEndpoints.youtubeSearchURL
                )
            },
            isStandardResponse: false
        )

        return result.mapData { $0.items?.first?.id?.videoId ?? "" }
    }

    private func buildTMDBPath(media: String, type: String) -> String {
        if type == "trending" {
            return "3/\(type)/\(media)/day"
        } else if type == "top_rated" || type == "upcoming" {
            return "3/\(media)/\(type)"
        } else if type == "search" {
            return "3/\(type)/\(media)"
        }
        return ""
    }
}
