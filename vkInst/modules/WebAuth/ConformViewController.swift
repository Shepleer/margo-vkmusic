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
        static let loginURL = "https://oauth.vk.com/authorize?client_id=7040198&display=mobile&redirect_uri=https://oauth.vk.com/blank.html&scope=photos,friends,wall&response_type=token"
        static let redirectURL = "https://oauth.vk.com/blank.html#"
    }
    
    @IBOutlet weak var containerStackView: UIStackView!
    var logInWebView: WKWebView!
    var presenter: ConformPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ConfigureWebView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
}

private extension ConformViewController {
    func ConfigureWebView() {
        let config = WKWebViewConfiguration()
        logInWebView = WKWebView(frame: containerStackView.frame, configuration: config)
        logInWebView.uiDelegate = self
        logInWebView.navigationDelegate = self
        containerStackView.addArrangedSubview(logInWebView)
        containerStackView.layoutIfNeeded()
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
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                self.presenter?.parseUserCredentials(redirectString: redirect)
            }
            let cookiesStore = webView.configuration.websiteDataStore.httpCookieStore
            cookiesStore.getAllCookies { [weak self] (cookies) in
                guard let self = self else { return }
                for cookie in cookies {
                    webView.configuration.websiteDataStore.httpCookieStore.delete(cookie, completionHandler: nil)
                }
            }
            presenter?.moveToMusicPlayerVC()
        }
    }
}



