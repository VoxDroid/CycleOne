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
        policyURL: URL? = PrivacyPolicyView.defaultPolicyURL()
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
        .navigationTitle("settings.privacy_policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    static func defaultPolicyURL(
        language: AppLanguage = AppLanguage.currentSelection()
    ) -> URL? {
        let fallbackURL = Bundle.main.url(
            forResource: "PrivacyPolicy",
            withExtension: "html"
        )

        return language.localizedResourceURL(
            forResource: "PrivacyPolicy",
            withExtension: "html"
        ) ?? fallbackURL
    }

    static func fallbackMessage(for policyURL: URL?) -> String? {
        policyURL == nil
            ? L10n.string(
                "privacy_policy.not_found",
                default: "Privacy Policy not found."
            )
            : nil
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
