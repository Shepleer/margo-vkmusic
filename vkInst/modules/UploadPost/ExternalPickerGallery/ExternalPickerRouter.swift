//
//  ExternalPickerRouter.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/16/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit
import Photos

protocol ExternalPickerRouterProtocol {
    func moveToUploadPostVC(assets: [PHAsset])
}

class ExternalPickerRouter {
    weak var vc: UIViewController?
}

extension ExternalPickerRouter: ExternalPickerRouterProtocol {
    func moveToUploadPostVC(assets: [PHAsset]) {
        guard let nav = vc?.navigationController else { return }
        nav.popViewController(animated: true)
        guard let uploadPostViewController = nav.topViewController as? UploadPostViewControllerProtocol else { return }
        uploadPostViewController.pickComplete(assets: assets)
    }
}
