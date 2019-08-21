//
//  ExternalPickerPresenter.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/16/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit
import Photos

protocol ExternalPickerPresenterProtocol {
    func pickDidEnded(assets: [PHAsset])
}

class ExternalPickerPresenter {
    
    private struct Constants {
        static let photosSortDescriptorKey = "creationDate"
    }
    
    weak var vc: ExternalPickerCollectionViewControllerProtocol?
    var router: ExternalPickerRouterProtocol?
    
    private var fetchResult: PHFetchResult<PHAsset>!
}

extension ExternalPickerPresenter: ExternalPickerPresenterProtocol {
    func pickDidEnded(assets: [PHAsset]) {
        router?.moveToUploadPostVC(assets: assets)
    }
    
    func viewDidLoad() {
        fetchGalleryAssets()
    }
}

private extension ExternalPickerPresenter {
    func fetchGalleryAssets() {
        if fetchResult == nil {
            let allPhotosOptions = PHFetchOptions()
            allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: Constants.photosSortDescriptorKey, ascending: true)]
            fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
            vc?.fetchComplete(fetchResult: fetchResult)
        }
    }
}
