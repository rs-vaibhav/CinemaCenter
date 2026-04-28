import Foundation
import SwiftData

struct TMDBAPIObject: Decodable {
    var results: [MediaTitle] = []
}

@Model
class MediaTitle: Decodable, Identifiable, Hashable {
    @Attribute(.unique) var id: Int?
    var title: String?
    var name: String?
    var overview: String?
    var posterPath: String?
    
    init(id: Int? = nil, title: String? = nil, name: String? = nil, overview: String? = nil, posterPath: String? = nil) {
        self.id = id
        self.title = title
        self.name = name
        self.overview = overview
        self.posterPath = posterPath
    }
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case name
        case overview
        case posterPath
    }
    
    required init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        overview = try container.decodeIfPresent(String.self, forKey: .overview)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
    }
    
    static var previewTitles = [
        MediaTitle(id: 1, title: "BeetleJuice", name: "BeetleJuice", overview: "A movie about BeetleJuice", posterPath: APIEndpoints.testMediaTitleURL),
        MediaTitle(id: 2, title: "Pulp Fiction", name: "Pulp Fiction", overview: "A movie about Pulp Fiction", posterPath: APIEndpoints.testMediaTitleURL2),
        MediaTitle(id: 3, title: "The Dark Knight", name: "The Dark Knight", overview: "A movie about the Dark Knight", posterPath: APIEndpoints.testMediaTitleURL3)
    ]
}



