import SwiftUI
import WebKit

struct YoutubePlayer: UIViewRepresentable {
    let videoId: String

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard !videoId.isEmpty else { return }
        let urlString = "https://www.youtube.com/embed/\(videoId)?playsinline=1"
        if let url = URL(string: urlString), uiView.url?.absoluteString != urlString {
            uiView.load(URLRequest(url: url))
        }
    }
}
