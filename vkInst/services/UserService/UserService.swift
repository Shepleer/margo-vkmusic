//
//  UserService.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 7/31/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation

typealias CommentsCompletion = (_ comments: CommentsResponse?, _ error: RequestError?, _ url: String) -> ()
typealias LikeButtonStateCompletion = (_ isLiked: Bool) -> ()
typealias LikesCountCompletion = (_ likes: Int?, _ error: RequestError?, _ url: String) -> ()
typealias CreatePostCompletion = (_ post: Post?, _ error: RequestError?, _ url: String) -> ()
typealias GetUserProfileInfoCompletion = (_ user: User?, _ error: RequestError?, _ url: String?) -> ()
typealias CreateCommentCompletion = (_ id: Int?, _ error: RequestError?, _ url: String) -> ()
protocol UserServiceProtocol {
    func getUserProfileInfo(completion: @escaping GetUserProfileInfoCompletion)
    func setLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion)
    func removeLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion)
    func createComment(postId: Int, ownerId: Int, message: String, completion: @escaping CreateCommentCompletion)
    func fetchPostComments(postId: Int, ownerId: Int, completion: @escaping CommentsCompletion)
    func getPost(with id: Int, completion: @escaping CreatePostCompletion)
    func createPost(message: String?, photosIds: [Int], completion: @escaping PostUploadCompletion, createPostCompletion: @escaping CreatePostCompletion)
}

class UserService {
    private struct RequestConfigurations {
        static let getUserProfileUrlTemplate = "https://api.vk.com/method/users.get?fields=photo_100,counters,screen_name&access_token=[token]&v=5.101"
        static let fetchPhotoCommentsUrlTemplate = "https://api.vk.com/method/wall.getComments?owner_id=[ownerId]&post_id=[postId]&need_likes=1&offset=0&count=20&sort=asc&preview_lenght=0&extended=1&access_token=[token]&v=5.101"
        static let createCommentUrlTemplate = "https://api.vk.com/method/wall.createComment?owner_id=[ownerId]&post_id=[postId]&message=[message]&access_token=[token]&v=5.101"
        static let removeLikeUrlTemplate = "https://api.vk.com/method/likes.delete?type=post&owner_id=[ownerId]&item_id=[postId]&access_token=[token]&v=5.101"
        static let setLikeUrlTemplate = "https://api.vk.com/method/likes.add?type=post&owner_id=[ownerId]&item_id=[postId]&access_token=[token]&v=5.101"
        static let getPostUrlTemplate = "https://api.vk.com/method/wall.getById?posts=[userId]_[id]&access_token=[token]&v=5.101"
        static let createPostUrlTemplate = "https://api.vk.com/method/wall.post?[userMessage][attachments]&access_token=[token]&v=5.101"
    }
    
    private var requestService: APIService
    private var user: User?
    private let userId = UserDefaults.standard.string(forKey: "userId") ?? "Token has expired"
    private let token = UserDefaults.standard.string(forKey: "accessToken") ?? "Token has expired"
    
    init(requestService: APIService) {
        self.requestService = requestService
    }
}

extension UserService: UserServiceProtocol {
    func getUserProfileInfo(completion: @escaping GetUserProfileInfoCompletion) {
        if let user = user {
            completion(user, nil, nil)
        } else {
            let url = RequestConfigurations.getUserProfileUrlTemplate
                        .replacingOccurrences(of: "[token]", with: token)
            requestService.getData(urlStr: url, method: .get, completion: { [weak self] (user: [User]?, err) in
                guard let self = self else { return }
                if let user = user?.first {
                    self.user = user
                    completion(user, nil, url)
                } else if let err = err as? RequestError {
                    completion(nil, err, url)
                }
            })
        }
    }
    
    func fetchPostComments(postId: Int, ownerId: Int, completion: @escaping CommentsCompletion) {
        let url = RequestConfigurations.fetchPhotoCommentsUrlTemplate
                    .replacingOccurrences(of: "[ownerId]", with: "\(ownerId)")
                    .replacingOccurrences(of: "[postId]", with: "\(postId)")
                    .replacingOccurrences(of: "[token]", with: token)
        requestService.getData(urlStr: url, method: .get, completion: { [weak self] (response: CommentsResponse?, err) in
            guard let self = self else { return }
            if let response = response {
                completion(response, nil, url)
            } else if let err = err as? RequestError {
                completion(nil, err, url)
            }
        })
    }
    
    func createComment(postId: Int, ownerId: Int, message: String, completion: @escaping CreateCommentCompletion) {
        let url = RequestConfigurations.createCommentUrlTemplate
                    .replacingOccurrences(of: "[ownerId]", with: "\(ownerId)")
                    .replacingOccurrences(of: "[postId]", with: "\(postId)")
                    .replacingOccurrences(of: "[message]", with: "\(message)")
                    .replacingOccurrences(of: "[token]", with: token)
        requestService.getData(urlStr: url, method: .get, completion: { [weak self] (commentId: SendCommentResponse?, err) in
            guard let self = self else { return }
            if let id = commentId?.commentId {
                completion(id, nil, url)
            } else if let err = err as? RequestError {
                completion(nil, err, url)
            }
        })
    }
    
    func removeLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion) {
        let url = RequestConfigurations.removeLikeUrlTemplate
            .replacingOccurrences(of: "[ownerId]", with: "\(ownerId)")
            .replacingOccurrences(of: "[postId]", with: "\(postId)")
            .replacingOccurrences(of: "[token]", with: token)
        requestService.getData(urlStr: url, method: .get, body: nil, headers: nil, completion: { [weak self] (likes: LikesSet?, err) in
            guard let self = self else { return }
            if let likes = likes?.likes {
                completion(likes, nil, url)
            } else if let err = err as? RequestError {
                completion(nil, err, url)
            }
        })
    }
    
    func setLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion) {
        let url = RequestConfigurations.setLikeUrlTemplate
            .replacingOccurrences(of: "[ownerId]", with: "\(ownerId)")
            .replacingOccurrences(of: "[postId]", with: "\(postId)")
            .replacingOccurrences(of: "[token]", with: token)
        requestService.getData(urlStr: url, method: .get, body: nil, headers: nil, completion: { [weak self] (likes: LikesSet?, err) in
            guard let self = self else { return }
            if let likes = likes?.likes {
                completion(likes, nil, url)
            } else if let err = err as? RequestError {
                completion(nil, err, url)
            }
        })
    }
    
    func createPost(message: String?, photosIds: [Int], completion: @escaping PostUploadCompletion, createPostCompletion: @escaping CreatePostCompletion) {
        guard let url = buildCreatePostUrl(message: message, photosIds: photosIds) else { return }
        requestService.getData(urlStr: url, method: .get, completion: { [weak self] (response: CreatePostResponse?, err) in
            guard let self = self else { return }
            if let id = response?.postId {
                self.getPost(with: id, completion: createPostCompletion)
            } else if let err = err as? RequestError {
                completion(nil, err, url)
            }
        })
    }
    
    func getPost(with id: Int, completion: @escaping CreatePostCompletion) {
        let url = RequestConfigurations.getPostUrlTemplate
                .replacingOccurrences(of: "[userId]", with: "\(userId)")
                .replacingOccurrences(of: "[id]", with: "\(id)")
                .replacingOccurrences(of: "[token]", with: token)
        requestService.getData(urlStr: url, method: .get, completion: { [weak self] (response: [Post]?, err) in
            guard let self = self else { return }
            if let post = response?.first {
                completion(post, nil, url)
            } else if let err = err as? RequestError {
                completion(nil, err, url)
            }
        })
    }
}

private extension UserService {
    func buildCreatePostUrl(message: String?, photosIds: [Int]) -> String? {
        guard message != nil || (photosIds.isEmpty == false) else { return nil }
        let ownerId = userId
        var attachments = ""
        var userMessage = ""
        if let message = message, message.isEmpty == false {
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
        let url = RequestConfigurations.createPostUrlTemplate
                    .replacingOccurrences(of: "[userMessage]", with: "\(userMessage)")
                    .replacingOccurrences(of: "[attachments]", with: attachments)
                    .replacingOccurrences(of: "[token]", with: token)
        return url
    }
}
