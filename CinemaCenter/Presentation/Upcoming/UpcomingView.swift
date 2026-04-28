import SwiftUI

struct UpcomingView: View {
    let viewModel = UpcomingViewModel()

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                viewModel.status.when(
                    initial: { AnyView(EmptyView()) },
                    loading: {
                        AnyView(
                            ProgressView()
                                .frame(width: geo.size.width, height: geo.size.height)
                        )
                    },
                    loaded: {
                        AnyView(VerticalListView(titles: viewModel.movies, canDelete: false))
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
                await viewModel.getUpcomingMovies()
            }
        }

    }
}

#Preview {
    UpcomingView()
}
