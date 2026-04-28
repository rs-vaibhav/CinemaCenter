import Foundation
import Observation

@Observable
class MediaTitleDetailViewModel {
    private(set) var status: StateStatus = .initial
    private(set) var videoId: String = ""

    private let repository: MediaRepository

    init(repository: MediaRepository = MediaRepositoryImpl()) {
        self.repository = repository
    }

    func getVideoId(for title: String) async {
        status = .loading
        let state = await repository.getMovieVideoId(query: title)
        state.when(
            success: {
                videoId = $0
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
