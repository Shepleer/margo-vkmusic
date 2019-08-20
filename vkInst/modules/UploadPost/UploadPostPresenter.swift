//
//  UploadPostPresenter.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/13/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import UIKit
import Photos

protocol UploadPostPresenterProtocol {
    func viewDidLoad()
    func uploadPost(message: String?, completion: @escaping PostUploadCompletion)
    func uploadImages(images: [UIImage])
    func moveBack()
    func presentGallery()
}

class UploadPostPresenter {
    weak var vc: UploadPostViewControllerProtocol?
    var uploadService: UploadServiceProtocol?
    var router: UploadPostRouterProtocol?
}

extension UploadPostPresenter: UploadPostPresenterProtocol {
    func viewDidLoad() {
        uploadService?.getWallUploadServer()
        
    }
    
    func uploadPost(message: String?, completion: @escaping PostUploadCompletion) {
        uploadService?.createPost(message: message, completion: completion)
    }
    
    func uploadImages(images: [UIImage]) {
        uploadService?.pushImagesToUpload(images)
    }
    
    func moveBack() {
        router?.moveBackToGalleryScreen()
    }
    
    func presentGallery() {
        router?.presentExternalGalleryViewController()
    }
}

private extension UploadPostPresenter {
    
}
