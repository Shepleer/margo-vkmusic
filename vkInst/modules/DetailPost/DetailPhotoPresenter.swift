//
//  DetailPhotoPresenter.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/2/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import Photos
protocol DetailPhotoPresenterProtocol {
    func viewDidLoad()
    func fetchComments(postId: Int, ownerId: Int)
    func commentsDownloaded()
    func sendComment(postId: Int, ownerId: Int, commentText: String)
    func setLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion)
    func removeLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion)
}

class DetailPhotoPresenter {
    weak var vc: DetailPhotoViewController?
    var router: DetailPhotoRouterProtocol?
    var pagingService: CommentsPageServiceProtocol?
    var userService: UserService?
    
}

extension DetailPhotoPresenter: DetailPhotoPresenterProtocol {
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
        pagingService?.nextFetch(postId: postId, ownerId: ownerId, completion: { (comments) in
            self.vc?.configureDataSource(comments: comments)
        })
    }
}

private extension DetailPhotoPresenter {
    
}
