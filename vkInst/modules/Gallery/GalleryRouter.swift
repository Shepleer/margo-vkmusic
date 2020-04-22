//
//  ImagesRouter.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/29/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol GalleryRouterProtocol {
    func moveToDetailScreen(post: Post, currentPage: Int, profile: User)
    func moveToUploadPostScreen()
    func moveToSettingsScreen()
    func moveToLogInScreen()
}

class ImagesRouter {
    weak var vc: UIViewController?
}

extension ImagesRouter: GalleryRouterProtocol {
    func moveToDetailScreen(post: Post, currentPage: Int, profile: User) {
        guard let viewController = Builder.shared.buildDetailPhotoScreen(data: post, currentPage: currentPage, profile: profile) else { return }
        vc?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func moveToUploadPostScreen() {
        guard let viewController = Builder.shared.buildUploadPostScreen() else { return }
        vc?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func moveToSettingsScreen() {
        guard let viewController = Builder.shared.buildSettingsScreen() else { return }
        vc?.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func moveToLogInScreen() {
        guard let galleryViewController = vc as? GalleryViewController,
            let viewController = Builder.shared.buildLogInScreen(),
            let window = UIApplication.shared.keyWindow,
            let rootViewController = window.rootViewController else { return }
        viewController.view.frame = rootViewController.view.frame
        viewController.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            window.rootViewController = viewController
        }) { (complete) in
            galleryViewController.viewControllerWillReleased()
        }
    }
}
