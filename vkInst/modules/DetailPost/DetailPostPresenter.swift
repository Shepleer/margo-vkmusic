//
//  DetailPhotoPresenter.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/2/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import Photos
protocol DetailPostPresenterProtocol {
    func viewDidLoad()
    func fetchComments(postId: Int, ownerId: Int)
    func commentsDownloaded()
    func sendComment(postId: Int, ownerId: Int, commentText: String)
    func setLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion)
    func removeLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion)
    func downloadPhoto(url: String, progress: @escaping DownloadProgress, completion: @escaping PhotoLoadingCompletion)
    func downloadGif(url: String, progress: @escaping DownloadProgress, completion: @escaping PhotoLoadingCompletion)
    func invalidateDownloadService()
    func fetchPostMetadata(postId: Int, completion: @escaping CreatePostCompletion)
}

class DetailPostPresenter {
    weak var viewController: DetailPostViewControllerProtocol?
    var router: DetailPostRouterProtocol?
    var pagingService: CommentsPageServiceProtocol?
    var userService: UserServiceProtocol?
    var downloadService: DownloadServiceProtocol?
}

extension DetailPostPresenter: DetailPostPresenterProtocol {
    func viewDidLoad() {
        
    }
    
    func removeLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion) {
        userService?.removeLike(postId: postId, ownerId: ownerId, completion: completion)
    }
    
    func setLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion) {
        userService?.setLike(postId: postId, ownerId: ownerId, completion: completion)
    }
    
    func commentsDownloaded() {
        pagingService?.fetchComplete()
    }
    
    func sendComment(postId: Int, ownerId: Int, commentText: String) {
        userService?.createComment(postId: postId, ownerId: ownerId, message: commentText)
    }
    
    func fetchComments(postId: Int, ownerId: Int) {
        pagingService?.nextFetch(postId: postId, ownerId: ownerId, completion: { [weak self] (comments, profiles, groups) in
            guard let self = self else { return }
            self.viewController?.configureDataSource(comments: comments,profiles: profiles,groups: groups)
        })
    }
    
    func downloadPhoto(url: String, progress: @escaping DownloadProgress, completion: @escaping PhotoLoadingCompletion) {
        downloadService?.downloadImage(url: url, progress: progress, completion: completion)
    }
    
    func downloadGif(url: String, progress: @escaping DownloadProgress, completion: @escaping PhotoLoadingCompletion) {
        downloadService?.downloadGif(url: url, progress: progress, completion: completion)
    }
    
    func invalidateDownloadService() {
        downloadService?.invalidateSession()
    }
    
    func fetchPostMetadata(postId: Int, completion: @escaping CreatePostCompletion) {
        userService?.getPost(with: postId, completion: completion)
    }
    
    func refreshData() {
        pagingService?.refreshPagination()
    }
}

private extension DetailPostPresenter {
    
}
