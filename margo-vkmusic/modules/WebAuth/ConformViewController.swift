//
//  ConformViewController.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/2/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit
import WebKit

class ConformViewController: UIViewController, WKUIDelegate {
    private struct Constants {
        static let loginURL = "https://oauth.vk.com/authorize?client_id=7040198&display=mobile&redirect_uri=https://oauth.vk.com/blank.html&scope=photos,friends&response_type=token"
        static let redirectURL = "https://oauth.vk.com/blank.html#"
    }
    
    var logInWebView: WKWebView!
    var presenter: ConformPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        ConfigureWebView()
    }
}

private extension ConformViewController {
    func ConfigureWebView() {
        let config = WKWebViewConfiguration()
        logInWebView = WKWebView(frame: .null, configuration: config)
        logInWebView.uiDelegate = self
        logInWebView.navigationDelegate = self
        view = logInWebView
        let url = URL(string: Constants.loginURL)
        let req = URLRequest(url: url!)
        logInWebView.load(req)
    }
}

extension ConformViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        let redirect = logInWebView.url!.relativeString
        let index = redirect.index(redirect.startIndex, offsetBy: 30)
        if redirect[...index] == Constants.redirectURL[...index] {
            DispatchQueue.global().async {
                self.presenter?.parseUserCredentials(redirectString: redirect)
            }
            presenter?.moveToMusicPlayerVC()
        }
    }
}



