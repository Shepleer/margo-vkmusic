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
    func uploadPost(message: String?, completion: @escaping PostUploadCompletion, createPostCompletion: @escaping CreatePostCompletion)
    func moveBack(newPost: Post)
    func presentGallery()
    func cancelUpload(index: Int)
    func updateDataSource(assets: [PHAsset])
    func getCountOfUploadItems() -> Int
    func getUploadImage(at indexPath: IndexPath) -> UploadImage
    func invalidateSession()
    func isHaveImagesToUpload() -> Bool
}

class UploadPostPresenter {
    weak var vc: UploadPostViewControllerProtocol?
    var uploadService: UploadServiceProtocol?
    var router: UploadPostRouterProtocol?
    var userService: UserServiceProtocol?
    var uploadImages = [UploadImage]()
    var requestManager = PHImageManager()
}

extension UploadPostPresenter: UploadPostPresenterProtocol {
    
    func viewDidLoad() {
        uploadService?.getWallUploadServer()
    }
    
    func uploadPost(message: String?, completion: @escaping PostUploadCompletion, createPostCompletion: @escaping CreatePostCompletion) {
        var photosIds = [Int]()
        for uploadImage in uploadImages {
            if let id = uploadImage.id {
                photosIds.append(id)
            }
        }
        userService?.createPost(message: message, photosIds: photosIds, completion: completion, createPostCompletion: createPostCompletion)
    }
    
    func isHaveImagesToUpload() -> Bool {
        return !uploadImages.isEmpty
    }
    
    func invalidateSession() {
        uploadService?.invalidateSession()
    }
    
    func moveBack(newPost: Post) {
        invalidateSession()
        router?.moveBackToGalleryScreen(newPost: newPost)
    }
    
    func presentGallery() {
        router?.presentExternalGalleryViewController()
    }
    
    func updateDataSource(assets: [PHAsset]) {
        guard assets.isEmpty == false else { return }
        var nextUploadImages = [UploadImage]()
        for asset in assets {
            let uploadImage = UploadImage(asset: asset)
            nextUploadImages.append(uploadImage)
        }
        let deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = deliveryMode
        uploadImages.append(contentsOf: nextUploadImages)
        for uploadImage in nextUploadImages {
            requestData(uploadImage: uploadImage, options: requestOptions)
        }
    }
    
    func cancelUpload(index: Int) {
        let fileName = uploadImages[index].fileName
        uploadService?.cancelUpload(fileName: fileName)
    }
    
    func startUploading() {
        guard uploadImages.isEmpty == false else { return }
        let deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = deliveryMode
        for uploadImage in uploadImages {
            requestData(uploadImage: uploadImage, options: requestOptions)
        }
    }
    
    func requestData(uploadImage: UploadImage, options: PHImageRequestOptions) {
        requestManager.requestImageData(for: uploadImage.asset, options: options) { [weak self] (data, str, orientation, nil) in
            guard let self = self,
                let data = data else { return }
            self.uploadRequestedData(data: data, uploadImage: uploadImage)
        }
    }
    
    func uploadRequestedData(data: Data, uploadImage: UploadImage) {
        self.uploadService?.transferPhotosToServer(imageData: data, fileName: uploadImage.fileName, progress: { [weak self] (progress) in
            guard let self = self,
                let i = self.uploadImages.firstIndex(where: { $0.fileName == uploadImage.fileName }) else { return }
            self.uploadImages[i].progress = progress
            self.vc?.setProgress(at: i, progress: progress)
        }, completion: { [weak self] (id, err, url) in
            guard let self = self,
                let id = id,
                let i = self.uploadImages.firstIndex(where: { $0.fileName == uploadImage.fileName }) else { return }
            self.uploadImages[i].id = id
            self.vc?.uploadComplete(at: i, id: id)
        }, cancel: { [weak self] (isCanceled) in
            guard let self = self,
                let i = self.uploadImages.firstIndex(where: { $0.fileName == uploadImage.fileName }) else { return }
            self.uploadImages.remove(at: i)
            self.vc?.deleteCell(at: i)
        })
    }
    
    func getCountOfUploadItems() -> Int {
        return uploadImages.count
    }
    
    func getUploadImage(at indexPath: IndexPath) -> UploadImage {
        let item = indexPath.item
        return uploadImages[item]
    }
}

private extension UploadPostPresenter {
    
}
