//
//  ImagesRouter.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/29/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol ImagesRouterProtocol {
    func moveToDetailScreen(post: Post, profile: User)
    func moveToUploadPostScreen()
    func moveToSettingsScreen()
}

class ImagesRouter {
    weak var vc: UIViewController?
}

extension ImagesRouter: ImagesRouterProtocol {
    func moveToDetailScreen(post: Post, profile: User) {
        guard let viewController = Builder.shared.buildDetailPhotoScreen(data: post, profile: profile) else { return }
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
}
