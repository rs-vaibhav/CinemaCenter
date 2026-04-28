import Foundation

@Observable
class SearchViewModel {
    private(set) var errorMessage: String?
    private(set) var searchMediaTitles: [MediaTitle] = []
    
    private let repository: MediaRepository
    
    init(repository: MediaRepository = MediaRepositoryImpl()) {
        self.repository = repository
    }
    
    func getSearchMediaTitles(by media: String, for title: String) async {
        errorMessage = nil
        let state: DataState<[MediaTitle]>
        
        if title.isEmpty {
            if media == "movie" {
                state = await repository.getTrendingMovies()
            } else if media == "tv" {
                state = await repository.getTrendingTV()
            } else {
                return
            }
        } else {
            state = await repository.search(query: title, media: media)
        }
        
        state.when(
            success: { searchMediaTitles = $0 },
            failure: { message, _ in errorMessage = message },
            loading: { }
        )
    }

}


