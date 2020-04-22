//
//  ImagesPresenter.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/4/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol GalleryPresenterProtocol {
    func viewDidLoad()
    func postsDownloaded()
    func cancelDownload(url: String)
    func loadImage(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ())
    func loadGif(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ())
    func setLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion)
    func removeLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion)
    func nextFetch()
    func fetchComments(postId: Int, ownerId: Int, completion: @escaping CommentsCompletion)
    func checkIsAllLoaded() -> Bool
    func moveToUploadPostScreen()
    func moveToDetailScreen(post: Post, currentPage: Int, profile: User)
    func moveToSettingsScreen()
    func releaseDownloadSession()
    func getProfile()
    func refreshPageService()
    func moveToLogInScreen()
}

class GalleryPresenter: NSObject {
    weak var vc: GalleryViewControllerProtocol?
    var service: APIServiceProtocol?
    var downloadService: DownloadService?
    var userService: UserServiceProtocol?
    var pageService: PageServiceProtocol?
    var router: GalleryRouterProtocol?
}

extension GalleryPresenter: GalleryPresenterProtocol {
    
    func viewDidLoad() {
        getProfile()
    }
    
    func cancelDownload(url: String) {
        downloadService?.cancelDownload(url: url)
    }
    
    func postsDownloaded() {
        pageService?.fetchComplete()
    }
    
    func loadImage(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ()) {
        downloadService?.downloadMedia(url: url, type: .image, progress: progress, completion: completion)
    }
    
    func loadGif(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ()) {
        downloadService?.downloadMedia(url: url, type: .gif, progress: progress, completion: completion)
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
    
    func moveToUploadPostScreen() {
        router?.moveToUploadPostScreen()
    }
    
    func moveToDetailScreen(post: Post, currentPage: Int, profile: User) {
        router?.moveToDetailScreen(post: post, currentPage: currentPage, profile: profile)
    }
    
    func moveToSettingsScreen() {
        router?.moveToSettingsScreen()
    }
    
    func releaseDownloadSession() {
        downloadService?.invalidateSession()
    }
    
    func getProfile() {
        userService?.getUserProfileInfo(completion: { [weak self] (user, err, url) in
            guard let self = self else { return }
            if let avatarUrl = user?.avatarPhotoUrl {
                self.downloadService?.downloadMedia(url: avatarUrl, type: .image, progress: { (progress) in
                }, completion: { [weak self] (img, err) in
                    guard let self = self else { return }
                    self.vc?.loadAvatar(image: img)
                })
            }
            if let user = user {
                self.vc?.setProfileData(user: user, error: nil)
            } else if let error = err {
                self.vc?.setProfileData(user: nil, error: error)
            }
        })
    }
    
    func refreshPageService() {
        pageService?.refreshPageService()
    }
    
    func moveToLogInScreen() {
        router?.moveToLogInScreen()
    }
}
