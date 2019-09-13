//
//  UserService.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 7/31/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation

typealias CommentsCompletion = (_ comments: CommentsResponse?) -> ()
typealias LikeButtonStateCompletion = (_ isLiked: Bool) -> ()
typealias LikesCountCompletion = (_ likes: Int) -> ()
typealias CreatePostCompletion = (_ post: Post) -> ()
protocol UserServiceProtocol {
    func getUserProfileInfo(completion: @escaping (_ user: User) -> ())
    func setLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion)
    func removeLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion)
    func createComment(postId: Int, ownerId: Int, message: String)
    func fetchPostComments(postId: Int, ownerId: Int, completion: @escaping CommentsCompletion)
    func getPost(with id: Int, completion: @escaping CreatePostCompletion)
    func createPost(message: String?, photosIds: [Int], completion: @escaping PostUploadCompletion, createPostCompletion: @escaping CreatePostCompletion)
}

class UserService {
    private var requestService: APIService
    private var user: User?
    private let userId = UserDefaults.standard.string(forKey: "userId") ?? "Token has expired"
    private let token = UserDefaults.standard.string(forKey: "accessToken") ?? "Token has expired"
    
    init(requestService: APIService) {
        self.requestService = requestService
    }
}

extension UserService: UserServiceProtocol {
    func getUserProfileInfo(completion: @escaping (_ user: User) -> ()) {
        if let user = user {
            completion(user)
        } else {
            let url = "https://api.vk.com/method/users.get?fields=photo_100,counters,screen_name&access_token=\(token)&v=5.101"
            requestService.getData(urlStr: url, method: .get, completion: { [weak self] (user: [User]?, err) in
                guard let self = self,
                    let user = user?.first else { return }
                self.user = user
                completion(user)
            })
        }
    }
    
    func fetchPostComments(postId: Int, ownerId: Int, completion: @escaping CommentsCompletion) {
        let url = "https://api.vk.com/method/wall.getComments?owner_id=\(ownerId)&post_id=\(postId)&need_likes=1&offset=0&count=20&sort=asc&preview_lenght=0&extended=1&access_token=\(token)&v=5.101"
        requestService.getData(urlStr: url, method: .get, completion: { [weak self] (response: CommentsResponse?, err) in
            guard let self = self,
                let response = response else { return }
            completion(response)
        })
    }
    
    func createComment(postId: Int, ownerId: Int, message: String) {
        let url = "https://api.vk.com/method/wall.createComment?owner_id=\(ownerId)&post_id=\(postId)&message=\(message)&access_token=\(token)&v=5.101"
        requestService.getData(urlStr: url, method: .get, completion: { [weak self] (commId: SendCommentResponse?, err) in })
    }
    
    func removeLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion) {
        let likesDelete_photos = "https://api.vk.com/method/likes.delete?type=post&owner_id=\(ownerId)&item_id=\(postId)&access_token=\(token)&v=5.101"
        requestService.getData(urlStr: likesDelete_photos, method: .get, body: nil, headers: nil, completion: { [weak self] (likes: LikesSet?, err) in
            guard let self = self,
                let likes = likes?.likes else { return }
            completion(likes)
        })
    }
    
    func setLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion) {
        let likesAdd_post = "https://api.vk.com/method/likes.add?type=post&owner_id=\(ownerId)&item_id=\(postId)&access_token=\(token)&v=5.101"
        requestService.getData(urlStr: likesAdd_post, method: .get, body: nil, headers: nil, completion: { [weak self] (likes: LikesSet?, err) in
            guard let self = self else { return }
            if let likes = likes?.likes {
                completion(likes)
            }
            if let err = err as? VkApiRequestError {
                print(err)
            }
        })
    }
    
    func createPost(message: String?, photosIds: [Int], completion: @escaping PostUploadCompletion, createPostCompletion: @escaping CreatePostCompletion) {
        guard message != nil || (photosIds.isEmpty == false) else { return }
        let ownerId = userId
        var attachments = ""
        var userMessage = ""
        if let message = message {
            userMessage = "message=\(message)"
            if photosIds.isEmpty == false {
                userMessage.append("&")
            }
        }
        if photosIds == photosIds {
            if !photosIds.isEmpty {
                attachments.append("attachments=")
                for i in 0...photosIds.count - 1 {
                    let attachment = "photo\(ownerId)_\(photosIds[i])"
                    if i != photosIds.count - 1 {
                        attachments.append(attachment + ",")
                    } else {
                        attachments.append(attachment)
                    }
                }
            }
        }
        let url = "https://api.vk.com/method/wall.post?\(userMessage)\(attachments)&access_token=\(token)&v=5.101"
        
        requestService.getData(urlStr: url, method: .get, completion: { [weak self] (response: CreatePostResponse?, err) in
            guard let self = self else { return }
            if let id = response?.postId {
                self.getPost(with: id, completion: createPostCompletion)
            }
        })
    }
    
    func getPost(with id: Int, completion: @escaping CreatePostCompletion) {
        let url = "https://api.vk.com/method/wall.getById?posts=\(userId)_\(id)&access_token=\(token)&v=5.101"
        requestService.getData(urlStr: url, method: .get, completion: { [weak self] (response: [Post]?, err) in
            guard let self = self,
                let post = response?.first else { return }
            completion(post)
        })
    }
}
