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
}

class ImagesRouter {
    weak var vc: UIViewController?
}

extension ImagesRouter: ImagesRouterProtocol {
    func moveToDetailScreen(post: Post, profile: User) {
        let viewController = Builder.shared.buildDetailPhotoScreen(data: post, profile: profile)
        vc?.navigationController?.pushViewController(viewController, animated: true)
    }
}
