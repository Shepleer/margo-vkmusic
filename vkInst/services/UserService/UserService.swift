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
protocol UserServiceProtocol {
    func getUserProfileInfo(completion: @escaping (_ user: User) -> ())
    func setLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion)
    func removeLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion)
    func createComment(postId: Int, ownerId: Int, message: String)
    func fetchPostComments(postId: Int, ownerId: Int, completion: @escaping CommentsCompletion)
}

class UserService {
    var requestService: APIService?
    private var user: User?
    private struct RequestConfigurations {
        static let userId = UserDefaults.standard.string(forKey: "userId")!
        static let token = UserDefaults.standard.string(forKey: "accessToken")!
        static let userGet = "https://api.vk.com/method/users.get?fields=photo_100,counters,screen_name&access_token=\(token)&v=5.101"
        static let test = "https://api.vk.com/method/execute?code=return[API.users.isAppUser()];&access_token=\(token)&v=5.101"
    }
}

extension UserService: UserServiceProtocol {
    func getUserProfileInfo(completion: @escaping (_ user: User) -> ()) {
        if let user = user {
            completion(user)
        } else {
            requestService?.getData(urlStr: RequestConfigurations.userGet, method: .get, completion: { (user: [User]?, err) in
                if let user = user?[0] {
                    self.user = user
                    completion(user)
                }
            })
        }
    }
    
    func fetchPostComments(postId: Int, ownerId: Int, completion: @escaping CommentsCompletion) {
        let url = "https://api.vk.com/method/wall.getComments?owner_id=\(ownerId)&post_id=\(postId)&need_likes=1&offset=0&count=20&sort=asc&preview_lenght=0&extended=1&access_token=\(RequestConfigurations.token)&v=5.101"
        requestService?.getData(urlStr: url, method: .get, completion: { (response: CommentsResponse?, err) in
            if let response = response {
                completion(response)
            }
        })
    }
    
    func createComment(postId: Int, ownerId: Int, message: String) {
        let url = "https://api.vk.com/method/wall.createComment?owner_id=\(ownerId)&post_id=\(postId)&message=\(message)&access_token=\(RequestConfigurations.token)&v=5.101"
        requestService?.getData(urlStr: url, method: .get, completion: { (commId: SendCommentResponse?, err) in })
    }
    
    func removeLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion) {
        let likesDelete_photos = "https://api.vk.com/method/likes.delete?type=post&owner_id=\(ownerId)&item_id=\(postId)&access_token=\(RequestConfigurations.token)&v=5.101"
        requestService?.getData(urlStr: likesDelete_photos, method: .get, body: nil, headers: nil, completion: { (likes: LikesSet?, err) in
            if let likes = likes?.likes {
                completion(likes)
            }
        })
    }
    
    func setLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion) {
        let likesAdd_post = "https://api.vk.com/method/likes.add?type=post&owner_id=\(ownerId)&item_id=\(postId)&access_token=\(RequestConfigurations.token)&v=5.101"
        requestService?.getData(urlStr: likesAdd_post, method: .get, body: nil, headers: nil, completion: { (likes: LikesSet?, err) in
            if let likes = likes?.likes {
                completion(likes)
            }
        })
    }
}
