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
    func moveBackToGalleryScreen()
    func presentExternalGalleryViewController()
}

class UploadPostRouter {
    weak var vc: UIViewController?
}

extension UploadPostRouter: UploadPostRouterProtocol {
    func moveBackToGalleryScreen() {
        guard let nav = vc?.navigationController else { return }
        nav.popViewController(animated: true)
    }
    
    func presentExternalGalleryViewController() {
        guard let nav = vc?.navigationController else { return }
        guard let viewController = Builder.shared.buildExternalGalleryViewController() else { return }
        nav.pushViewController(viewController, animated: true)
    }
}
