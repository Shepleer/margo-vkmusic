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
    func uploadPhoto(data: Data, fileName: String, progress: @escaping Update, completion: @escaping PostUploadCompletion)
    func uploadPost(message: String?, photosIds: [Int], completion: @escaping PostUploadCompletion)
    func moveBack()
    func presentGallery()
}

class UploadPostPresenter {
    weak var vc: UploadPostViewControllerProtocol?
    var uploadService: UploadServiceProtocol?
    var router: UploadPostRouterProtocol?
    var userService: UserService?
}

extension UploadPostPresenter: UploadPostPresenterProtocol {
    func viewDidLoad() {
        uploadService?.getWallUploadServer()
    }
    
    func uploadPost(message: String?, photosIds: [Int], completion: @escaping PostUploadCompletion) {
        userService?.createPost(message: message, photosIds: photosIds, completion: completion)
    }
    
    func moveBack() {
        router?.moveBackToGalleryScreen()
    }
    
    func presentGallery() {
        router?.presentExternalGalleryViewController()
    }
    
    func uploadPhoto(data: Data, fileName: String, progress: @escaping Update, completion: @escaping PostUploadCompletion) {
        uploadService?.transferPhotosToServer(imageData: data, fileName: fileName, progress: progress, completion: completion)
    }
}

private extension UploadPostPresenter {
    
}
