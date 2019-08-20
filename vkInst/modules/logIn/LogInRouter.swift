//
//  LogInRouter.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/2/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol LogInRouterProtocol {
    func presentWebView()
}

class LogInRouter {
    weak var vc: UIViewController?
}

extension LogInRouter: LogInRouterProtocol {
    func presentWebView() {
        guard let module = Builder.shared.buildConformWebView() else { return }
        vc?.navigationController?.pushViewController(module, animated: true)
    }
}
