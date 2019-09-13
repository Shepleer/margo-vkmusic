//
//  UploadPostRouter.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/16/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import UIKit

protocol UploadPostRouterProtocol {
    func moveBackToGalleryScreen(newPost: Post)
    func presentExternalGalleryViewController()
}

class UploadPostRouter {
    weak var vc: UIViewController?
}

extension UploadPostRouter: UploadPostRouterProtocol {
    func moveBackToGalleryScreen(newPost: Post) {
        guard let nav = vc?.navigationController,
            let imagesViewController = nav.viewControllers.first as? GalleryViewControllerProtocol else { return }
        imagesViewController.insertNewPost(post: newPost)
        nav.popViewController(animated: true)
    }
    
    func presentExternalGalleryViewController() {
        guard let nav = vc?.navigationController else { return }
        guard let viewController = Builder.shared.buildExternalGalleryViewController() else { return }
        nav.pushViewController(viewController, animated: true)
    }
}
