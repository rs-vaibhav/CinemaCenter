import SwiftUI
 
struct ContentView: View {
    var body: some View {
        TabView{
            Tab(AppTexts.homeString,systemImage: AppTexts.homeIconString){
                HomeView()
            }
            Tab(AppTexts.upcomingString,systemImage: AppTexts.upcomingIconString){
                UpcomingView()
            }
            Tab(AppTexts.searchString,systemImage: AppTexts.searchIconString){
                SearchView()
            }
            Tab(AppTexts.downloadString,systemImage: AppTexts.downloadIconString){
                DownloadView()
            }
        }
    }
}

#Preview {
    ContentView()
}
