import SwiftData
import SwiftUI

struct DownloadView: View {
    @Query(sort: \MediaTitle.title) var savedMediaTitles: [MediaTitle]

    var body: some View {
        NavigationStack {
            if savedMediaTitles.isEmpty {
                Text("No Downloads")
                    .padding()
                    .font(.title3)
                    .bold()
            } else {
                VerticalListView(titles: savedMediaTitles, canDelete: true)
            }
        }
    }
}

#Preview {
    DownloadView()
}
