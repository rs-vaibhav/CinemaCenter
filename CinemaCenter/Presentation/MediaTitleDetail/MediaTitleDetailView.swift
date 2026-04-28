import SwiftData
import SwiftUI

struct MediaTitleDetailView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    let viewModel = MediaTitleDetailViewModel()

    let title: MediaTitle
    var titleName: String {
        return (title.name ?? title.title) ?? ""
    }

    var body: some View {
        GeometryReader { geometry in
            viewModel.status.when(
                initial: { AnyView(EmptyView()) },
                loading: {
                    AnyView(
                        ProgressView()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    )
                },
                loaded: {
                    AnyView(
                        ScrollView {
                            LazyVStack(alignment: .leading) {
                                YoutubePlayer(videoId: viewModel.videoId)
                                    .aspectRatio(1.3, contentMode: .fit)

                                Text(titleName)
                                    .bold()
                                    .font(.title2)
                                    .padding(5)

                                Text(title.overview ?? "")
                                    .padding(5)

                                HStack {
                                    Spacer()

                                    Button {
                                        let saveTitle = title
                                        saveTitle.title = titleName
                                        modelContext.insert(saveTitle)
                                        try? modelContext.save()
                                        dismiss()
                                    } label: {
                                        Text(AppTexts.downloadString)
                                            .ghostButton()
                                    }

                                    Spacer()
                                }
                            }
                        }
                    )
                },
                onError: { error in
                    AnyView(
                        Text(error?.localizedDescription ?? "Unknown Error")
                            .errorMessage()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    )
                },
                noInternet: {
                    AnyView(
                        Text("No Internet")
                            .errorMessage()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    )
                }
            )
        }
        .task {
            await viewModel.getVideoId(for: titleName)
        }
    }
}

#Preview {
    MediaTitleDetailView(title: MediaTitle.previewTitles[0])
}
