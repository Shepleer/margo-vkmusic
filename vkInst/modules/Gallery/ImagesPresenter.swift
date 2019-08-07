//
//  ImagesPresenter.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/4/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol ImagePresenterProtocol {
    func viewDidLoad()
    func imagesDownloaded()
    func cancelDownload(image: Image)
    func loadImage(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ())
    func setLike(photo: Image, completion: @escaping (_ likes: Int) -> ())
    func removeLike(photo: Image, completion: @escaping (_ likes: Int) -> ())
    func nextFetch()
    func fetchComments(photoData: Image, completion: @escaping CommentsCompletion)
    func checkIsAllLoaded() -> Bool
}

class ImagePresenter: NSObject {
    weak var vc: ImagesViewControllerProtocol?
    var service: APIServiceProtocol?
    var downloadService: DownloadService?
    var userService: UserService?
    var pageService: PageServiceProtocol?
    var router: ImagesRouterProtocol?
}

extension ImagePresenter: ImagePresenterProtocol {
    func viewDidLoad() {
        getProfile()
    }
    
    func cancelDownload(image: Image) {
        downloadService?.cancelDownload(image: image)
    }
    
    func imagesDownloaded() {
        pageService?.fetchComplete()
    }
    
    func loadImage(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ()) {
        downloadService?.downloadImage(url: url, progress: progress, completion: completion)
    }
    
    func setLike(photo: Image, completion: @escaping (_ likes: Int) -> ()) {
        userService?.setLike(photo: photo, completion: completion)
    }
    
    func removeLike(photo: Image, completion: @escaping (_ likes: Int) -> ()) {
        userService?.removeLike(photo: photo, completion: completion)
    }
    
    func fetchComments(photoData: Image, completion: @escaping CommentsCompletion) {
        userService?.fetchPhotoComments(photoData: photoData, completion: completion)
    }
    
    func nextFetch() {
        pageService?.nextFetch(completion: { (images) in
            self.vc?.configureWithPhotos(images: images)
        })
    }
    
    func checkIsAllLoaded() -> Bool {
        return pageService!.checkIsAllLoaded()
    }
}

private extension ImagePresenter {
    func getProfile() {
        userService?.getUserProfileInfo(completion: { (user) in
            self.downloadService?.downloadImage(url: user.avatarPhotoUrl!, progress: { (progress) in
            }, completion: { (img, err) in
                self.vc?.loadAvatar(image: img)
            })
            self.vc?.setProfileData(user: user)
        })
    }
}
