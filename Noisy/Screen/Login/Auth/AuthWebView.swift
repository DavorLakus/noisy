//
//  AuthWebView.swift
//  Noisy
//
//  Created by Davor Lakus on 13.06.2023..
//

import SwiftUI
import WebKit

struct AuthWebView: UIViewRepresentable {
    @ObservedObject var viewModel: AuthViewModel

    let webView = WKWebView()

    func makeUIView(context: UIViewRepresentableContext<AuthWebView>) -> WKWebView {
        self.webView.navigationDelegate = context.coordinator
        self.webView.load(URLRequest(url: viewModel.link))
        return self.webView
    }

    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<AuthWebView>) {
        return
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        private var viewModel: AuthViewModel

        init(_ viewModel: AuthViewModel) {
            self.viewModel = viewModel
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            guard let url = webView.url else {return}
            
            let components = URLComponents(string: url.absoluteString)
            guard
                let code = components?.queryItems?.first(where: { $0.name == "code"})?.value
            else {return}
            
            webView.isHidden = true
            
            webView.stopLoading()
            viewModel.codeReceived(code)
        }
    }

    func makeCoordinator() -> AuthWebView.Coordinator {
        Coordinator(viewModel)
    }
}
