import Foundation
import Observation

@Observable
class UpcomingViewModel {
    private(set) var status: StateStatus = .initial
    private(set) var movies: [MediaTitle] = []
    
    private let repository: MediaRepository
    
    init(repository: MediaRepository = MediaRepositoryImpl()) {
        self.repository = repository
    }
    
    func getUpcomingMovies() async {
        status = .loading
        let state = await repository.getUpcomingMovies()
        state.when(
            success: {
                movies = $0
                status = .loaded
            },
            failure: { _, error in
                print(error)
                status = .error(error: error)
            },
            loading: {
                status = .loading
            }
        )
    }

}
