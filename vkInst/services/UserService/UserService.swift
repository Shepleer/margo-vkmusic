//
//  UserService.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 7/31/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation

typealias LikeButtonStateCompletion = (_ isLiked: Bool) -> ()
typealias LikesCountCompletion = (_ likes: Int) -> ()
protocol UserServiceProtocol {
    func getUserProfileInfo(completion: @escaping (_ user: User) -> ())
    func fetchLikeList(photo: Image, setLikesCount: @escaping (_ likes: Int) -> (), setLikeButtonState: @escaping (_ isLiked: Bool) -> ())
    func setLike(photo: Image, completion: @escaping (_ likes: Int) -> ())
    func removeLike(photo: Image, completion: @escaping (_ likes: Int) -> ())
}

class UserSerice {
    var requestService: APIService?
    private var user: User?
    private struct RequestConfigurations {
        static let userId = UserDefaults.standard.string(forKey: "userId")!
        static let token = UserDefaults.standard.string(forKey: "accessToken")!
        static let userGet = "https://api.vk.com/method/users.get?fields=photo_100,counters,screen_name&access_token=\(token)&v=5.101"
    }
}

extension UserSerice: UserServiceProtocol {
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
    
    func setLike(photo: Image, completion: @escaping (_ likes: Int) -> ()) {
        let likesAdd_photos = "https://api.vk.com/method/likes.add?type=photo&owner_id=\(photo.ownerId!)&item_id=\(photo.id!)&access_token=\(RequestConfigurations.token)&v=5.101"
        requestService?.getData(urlStr: likesAdd_photos, method: .get, body: nil, headers: nil, completion: { (likes: LikesSet?, err) in
            completion((likes?.likes)!)
        })
    }
    
    func removeLike(photo: Image, completion: @escaping (_ likes: Int) -> ()) {
        let likesDelete_photos = "https://api.vk.com/method/likes.delete?type=photo&owner_id=\(photo.ownerId!)&item_id=\(photo.id!)&access_token=\(RequestConfigurations.token)&v=5.101"
        requestService?.getData(urlStr: likesDelete_photos, method: .get, body: nil, headers: nil, completion: { (likes: LikesSet?, err) in
            completion((likes?.likes)!)
        })
    }
    
    func fetchLikeList(photo: Image, setLikesCount: @escaping (_ likes: Int) -> (), setLikeButtonState: @escaping LikeButtonStateCompletion) {
        let likesGetList = "https://api.vk.com/method/likes.getList?type=photo&owner_id=\(photo.ownerId!)&item_id=\(photo.id!)&access_token=\(RequestConfigurations.token)&v=5.101"
        requestService?.getData(urlStr: likesGetList, method: .get, completion: { (list: LikesList?, err) in
            setLikesCount((list?.count)!)
        })
        isPhotoLiked(photo: photo, setLikeButtonState: setLikeButtonState)
    }
    
    func isPhotoLiked(photo: Image, setLikeButtonState: @escaping LikeButtonStateCompletion) {
        let likesIsLiked = "https://api.vk.com/method/likes.isLiked?user_id=\(RequestConfigurations.userId)&type=photo&owner_id=\(photo.ownerId!)&item_id=\(photo.id!)&access_token=\(RequestConfigurations.token)&v=5.101"
        requestService?.getData(urlStr: likesIsLiked, method: .get, completion: { (like: Like?, err) in
            if like?.liked == 0 {
                setLikeButtonState(false)
            } else {
                setLikeButtonState(true)
            }
        })
    }
}
