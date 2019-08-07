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
    func setLike(photo: Image, completion: @escaping (_ likes: Int) -> ())
    func removeLike(photo: Image, completion: @escaping (_ likes: Int) -> ())
    func fetchPhotoComments(photoData: Image, completion: @escaping CommentsCompletion)
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
    
    func fetchPhotoComments(photoData: Image, completion: @escaping CommentsCompletion) {
        let photosGetAllComments = "https://api.vk.com/method/photos.getComments?owner_id=\(photoData.ownerId!)&photo_id=\(photoData.id!)&need_likes=1&sort=asc&extended=1&access_token=\(RequestConfigurations.token)&v=5.101"
        requestService?.getData(urlStr: photosGetAllComments, method: .get, completion: { (response: CommentsResponse?, err) in
            completion(response)
        })
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
    
    func createComment(id: Int, ownerId: Int, message: String) {
        let url = "https://api.vk.com/method/photos.createComment?owner_id=\(ownerId)&photo_id=\(id)&message=\(message)&access_token=\(RequestConfigurations.token)&v=5.101"
        print(url)
        requestService?.getData(urlStr: url, method: .get, completion: { (likes: LikesSet?, err) in
        })
    }
}
