//
//  DetailPhotoPresenter.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/2/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation

protocol DetailPhotoPresenterProtocol {
    func viewDidLoad()
    func fetchComments(id: Int, ownerId: Int)
    func commentsDownloaded()
    func sendComment(id: Int, ownerId: Int, commentText: String)
    func setLike(photo: Image, completion: @escaping LikesCountCompletion)
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
    
    func removeLike(photo: Image, completion: @escaping LikesCountCompletion) {
        userService?.removeLike(photo: photo, completion: completion)
    }
    
    func setLike(photo: Image, completion: @escaping LikesCountCompletion) {
        userService?.setLike(photo: photo, completion: completion)
    }
    
    func commentsDownloaded() {
        pagingService?.fetchComplete()
    }
    
    func sendComment(id: Int, ownerId: Int, commentText: String) {
        userService?.createComment(id: id, ownerId: ownerId, message: commentText)
    }
    
    func fetchComments(id: Int, ownerId: Int) {
        pagingService?.nextFetch(id: id, ownerId: ownerId, completion: { (comments) in
            self.vc?.configureDataSource(comments: comments)
        })
    }
}

private extension DetailPhotoPresenter {
    
}
