import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) var modelContext
    private let viewModel = HomeViewModel()

    @State private var mediaTitleDetailPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $mediaTitleDetailPath) {
            GeometryReader { geo in
                ScrollView(.vertical) {
                    viewModel.status.when(
                        initial: { AnyView(EmptyView()) },
                        loading: {
                            AnyView(
                                ProgressView()
                                    .frame(width: geo.size.width, height: geo.size.height)
                            )
                        },
                        loaded: {
                            AnyView(
                                LazyVStack(spacing: 0) {
                                    AsyncImage(
                                        url: URL(string: viewModel.heroTitle.posterPath ?? "")
                                    ) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .clipped()
                                            .overlay {
                                                LinearGradient(
                                                    stops: [
                                                        Gradient.Stop(color: .clear, location: 0.8),
                                                        Gradient.Stop(color: .gradient, location: 1),
                                                    ],
                                                    startPoint: .top,
                                                    endPoint: .bottom
                                                )
                                            }
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    .frame(
                                        width: geo.size.width,
                                        height: geo.size.height * 0.85
                                    )

                                    HStack {
                                        Button {
                                            mediaTitleDetailPath.append(viewModel.heroTitle)
                                        } label: {
                                            Text(AppTexts.playString)
                                                .ghostButton()
                                        }

                                        Button {
                                            modelContext.insert(viewModel.heroTitle)
                                            try? modelContext.save()
                                        } label: {
                                            Text(AppTexts.downloadString)
                                                .ghostButton()
                                        }
                                    }

                                    HorizontalListView(
                                        header: AppTexts.trendingMovieString,
                                        titles: viewModel.trendingMovies
                                    ) { title in
                                        mediaTitleDetailPath.append(title)
                                    }
                                    HorizontalListView(
                                        header: AppTexts.trendingTVString,
                                        titles: viewModel.trendingTV
                                    ) { title in
                                        mediaTitleDetailPath.append(title)
                                    }
                                    HorizontalListView(
                                        header: AppTexts.topRatedMovieString,
                                        titles: viewModel.topRatedMovies
                                    ) { title in
                                        mediaTitleDetailPath.append(title)
                                    }
                                    HorizontalListView(
                                        header: AppTexts.topRatedTVString,
                                        titles: viewModel.topRatedTV
                                    ) { title in
                                        mediaTitleDetailPath.append(title)
                                    }
                                }
                            )
                        },
                        onError: { error in
                            AnyView(
                                Text(error?.localizedDescription ?? "Unknown Error")
                                    .errorMessage()
                                    .frame(width: geo.size.width, height: geo.size.height)
                            )
                        },
                        noInternet: {
                            AnyView(
                                Text("No Internet")
                                    .errorMessage()
                                    .frame(width: geo.size.width, height: geo.size.height)
                            )
                        }
                    )
                }
                .task {
                    await viewModel.getMediaTitles()
                }
                .navigationDestination(for: MediaTitle.self) { title in
                    MediaTitleDetailView(title: title)
                }
            }
            .ignoresSafeArea(edges: .top)
        }
    }
}

#Preview {
    HomeView()
}
