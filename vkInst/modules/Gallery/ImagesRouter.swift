//
//  ImagesRouter.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/29/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol ImagesRouterProtocol {
    func moveToDetailScreen(photo: Image, profile: User)
}

class ImagesRouter {
    weak var vc: UIViewController?
}

extension ImagesRouter: ImagesRouterProtocol {
    func moveToDetailScreen(photo: Image, profile: User) {
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let viewController = storyboard.instantiateViewController(withIdentifier: "detailVC")
        let viewController = Builder.shared.buildDetailPhotoScreen(data: photo, profile: profile)
        vc?.navigationController?.pushViewController(viewController, animated: true)
        
    }
}
