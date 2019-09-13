//
//  SettingRouter.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/21/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit


protocol SettingsRouterProtocol {
    func moveToLogInScreen()
}

class SettingsRouter {
    weak var vc: UIViewController?
}

extension SettingsRouter: SettingsRouterProtocol {
    func moveToLogInScreen() {
        guard let vc = vc,
            let viewController = Builder.shared.buildLogInScreen(),
            let window = UIApplication.shared.keyWindow,
            let imagesViewController = vc.navigationController?.viewControllers.first as? GalleryViewController,
            let rootViewController = window.rootViewController else { return }
        imagesViewController.viewControllerWillReleased()
        vc.view.frame = rootViewController.view.frame
        vc.view.layoutIfNeeded()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        }, completion: nil)
    }
}
