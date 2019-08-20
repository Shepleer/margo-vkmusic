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
    func postsDownloaded()
    func cancelDownload(image: Image)
    func loadImage(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ())
    func loadGif(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ())
    func setLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion)
    func removeLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion)
    func nextFetch()
    func fetchComments(postId: Int, ownerId: Int, completion: @escaping CommentsCompletion)
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
    
    func postsDownloaded() {
        pageService?.fetchComplete()
    }
    
    func loadImage(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ()) {
        downloadService?.downloadImage(url: url, progress: progress, completion: completion)
    }
    
    func loadGif(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ()) {
        downloadService?.downloadGif(url: url, progress: progress, completion: completion)
    }
    
    func fetchComments(postId: Int, ownerId: Int, completion: @escaping CommentsCompletion) {
        userService?.fetchPostComments(postId: postId, ownerId: ownerId, completion: completion)
    }
    
    func setLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion) {
        userService?.setLike(postId: postId, ownerId: ownerId, completion: completion)
    }
    
    func removeLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion) {
        userService?.removeLike(postId: postId, ownerId: ownerId, completion: completion)
    }
    
    func nextFetch() {
        pageService?.nextFetch(completion: { (posts) in
            self.vc?.configureWithPhotos(posts: posts)
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
