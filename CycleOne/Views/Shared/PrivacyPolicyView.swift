//
//  PrivacyPolicyView.swift
//  CycleOne
//
//  Created by Antigravity on 3/23/26.
//

import SwiftUI
import WebKit

struct PrivacyPolicyView: View {
    var body: some View {
        Group {
            if let url = Bundle.main.url(forResource: "PrivacyPolicy", withExtension: "html") {
                WebView(url: url)
            } else {
                Text("Privacy Policy not found.")
            }
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}
