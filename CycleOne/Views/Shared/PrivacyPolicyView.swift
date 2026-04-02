//
//  PrivacyPolicyView.swift
//  CycleOne
//
//  Created by Antigravity on 3/23/26.
//

import SwiftUI
import WebKit

struct PrivacyPolicyView: View {
    private let policyURL: URL?

    init(
        policyURL: URL? = Bundle.main.url(
            forResource: "PrivacyPolicy",
            withExtension: "html"
        )
    ) {
        self.policyURL = policyURL
    }

    var body: some View {
        Group {
            if let url = policyURL {
                WebView(url: url)
            }
            let fallbackMessage = Self.fallbackMessage(for: policyURL)
            Text(fallbackMessage ?? "")
                .opacity(fallbackMessage == nil ? 0 : 1)
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    static func fallbackMessage(for policyURL: URL?) -> String? {
        policyURL == nil ? "Privacy Policy not found." : nil
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    static func makeBaseWebView() -> WKWebView {
        WKWebView()
    }

    static func makeRequest(for url: URL) -> URLRequest {
        URLRequest(url: url)
    }

    func makeUIView(context: Context) -> WKWebView {
        Self.makeBaseWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = Self.makeRequest(for: url)
        uiView.load(request)
    }
}
