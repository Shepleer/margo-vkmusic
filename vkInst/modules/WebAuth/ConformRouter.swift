//
//  ConformRouter.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/2/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol ConformRouterProtocol {
    func moveToMainVC()
}

class ConformRouter: ConformRouterProtocol {
    func moveToMainVC() {
        guard let vc = Builder.shared.createGalleryVC() else { return }
        guard let window = UIApplication.shared.keyWindow else { return }
        guard let rootViewController = window.rootViewController else { return }
        vc.view.frame = rootViewController.view.frame
        vc.view.layoutIfNeeded()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = vc
        }, completion: nil)
    }
}
