import SwiftUI

struct SearchView: View {
    private let searchViewModel = SearchViewModel()

    @State private var searchByMovies = true
    @State private var searchText = ""
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                if let error = searchViewModel.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(.rect(cornerRadius: 10))
                }

                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                    ForEach(searchViewModel.searchMediaTitles) { title in
                        AsyncImage(url: URL(string: title.posterPath ?? "")) {
                            image in
                            image
                                .resizable()
                                .scaledToFit()
                                .clipShape(.rect(cornerRadius: 10))
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 120, height: 200)
                        .onTapGesture {
                            navigationPath.append(title)
                        }
                    }
                }
            }
            .navigationTitle(
                searchByMovies
                    ? AppTexts.movieSearchString : AppTexts.tvSearchString
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        searchByMovies.toggle()

                        Task {
                            await searchViewModel.getSearchMediaTitles(
                                by: searchByMovies ? "movie" : "tv",
                                for: searchText
                            )
                        }

                    } label: {
                        Image(
                            systemName: searchByMovies
                                ? AppTexts.movieIconString
                                : AppTexts.tvIconString
                        )
                    }
                }
            }
            .searchable(
                text: $searchText,
                prompt: searchByMovies
                    ? AppTexts.moviePlaceHolderString
                    : AppTexts.tvPlaceHolderString
            )
            .task(id: searchText) {
                try? await Task.sleep(for: .milliseconds(500))

                if Task.isCancelled {
                    return
                }

                await searchViewModel.getSearchMediaTitles(
                    by: searchByMovies ? "movie" : "tv",
                    for: searchText
                )
            }
            .navigationDestination(for: MediaTitle.self) { title in
                MediaTitleDetailView(title: title)
            }
        }
    }
}

#Preview {
    SearchView()
}
