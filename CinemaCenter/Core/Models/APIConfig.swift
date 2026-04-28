struct APIConfig: Decodable {
    let tmdbAPIKey: String
    let youtubeAPIKey: String

    init() {
        self.tmdbAPIKey = ""
        self.youtubeAPIKey = ""
    }
}
