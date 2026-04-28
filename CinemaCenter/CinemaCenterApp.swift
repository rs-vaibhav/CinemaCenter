import SwiftUI
import SwiftData

@main
struct CinemaCenterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: MediaTitle.self)
    }
}
