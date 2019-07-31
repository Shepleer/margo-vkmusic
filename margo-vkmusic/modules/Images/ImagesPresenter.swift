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
    func getPhotosUrl()
    func imagesDownloaded()
    func cancelDownload(image: Image)
    func loadImage(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ())
    func setLike(photo: Image)
    func getLikeList(photo: Image, completion: @escaping (_ likes: Int) -> ())
}

class ImagePresenter: NSObject {
    weak var vc: ImagesViewControllerProtocol?
    var service: APIServiceProtocol?
    var downloadService: DownloadService?
    var router: ImagesRouterProtocol?
    var images = [Image]()
    var isLoading = false
    
    private struct Requests {
        static let userId = UserDefaults.standard.string(forKey: "userId")!
        static let token = UserDefaults.standard.string(forKey: "accessToken")!
        static var offset = 0
        static let friends_get = "https://api.vk.com/method/friends.get?user_id=32707600&access_token=\(token)&v=5.101"
        static let users_getFollowers = "https://api.vk.com/method/users.getFollowers?user_id=32707600&access_token=\(token)&v=5.101"
        static let photos_getAll = "https://api.vk.com/method/photos.getAll?owner_id=32707600&access_token=\(token)&v=5.101"
        static let avatarUrl = "https://pp.userapi.com/c850632/v850632368/12f83a/F_KkO78daRs.jpg"
        static let profileInfo = "https://api.vk.com/method/account.getProfileInfo?access_token=\(token)&v=5.101"
        static let ownerId = 00
        static let id = 00
        let likesAdd_photos = "https://api.vk.com/method/likes.add?type=photo&owner_id=\(ownerId)&item_id=\(id)&access_token=\(token)&v=5.101"
        let likesDelete_photos = "https://api.vk.com/method/likes.delete?type=photo&owner_id=\(ownerId)&item_id=\(id)&access_token=\(token)&v=5.101"
        let likesIsLiked = "https://api.vk.com/method/likes.isLiked?user_id=\(Requests.userId)&type=photo&owner_id=\(ownerId)&item_id=\(id)&access_token=\(token)&v=5.101"
    }
}

extension ImagePresenter: ImagePresenterProtocol {
    func viewDidLoad() {
        self.getAvatar()
        self.getPhotosUrl()
        self.getCountOfFriendsAndFolowers()
        self.getAccountInformation()
    }
    
    func cancelDownload(image: Image) {
        downloadService?.cancelDownload(image: image)
    }
    
    func imagesDownloaded() {
        isLoading = false
    }
    
    func loadImage(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ()) {
        downloadService?.downloadImage(image: Image(img: nil, url: url, id: 0000000, ownerId: 228008), progress: progress, completion: completion)
    }
    
    func setLike(photo: Image) {
        let likesIsLiked = "https://api.vk.com/method/likes.isLiked?user_id=\(Requests.userId)&type=photo&owner_id=\(photo.ownerId!)&item_id=\(photo.id!)&access_token=\(Requests.token)&v=5.101"
        service?.getData(urlStr: likesIsLiked, method: .get, body: nil, headers: nil, completion: { (like: Like?, err) in
            if like?.liked == 0 {
                let likesAdd_photos = "https://api.vk.com/method/likes.add?type=photo&owner_id=\(photo.ownerId!)&item_id=\(photo.id!)&access_token=\(Requests.token)&v=5.101"
                self.service?.getData(urlStr: likesAdd_photos, method: .get, body: nil, headers: nil, completion: { (likes: LikesSet?, err) in
                    print("Like setted: \(likes?.likes)")
                })
            } else {
                let likesDelete_photos = "https://api.vk.com/method/likes.delete?type=photo&owner_id=\(photo.ownerId!)&item_id=\(photo.id!)&access_token=\(Requests.token)&v=5.101"
                self.service?.getData(urlStr: likesDelete_photos, method: .get, body: nil, headers: nil, completion: { (likes: LikesSet?, err) in
                    print("Like desetted: \(likes?.likes)")
                })
            }
        })
    }
    
    func removeLike(photo: Image, completion: @escaping (_ likes: Int) -> ()) {
        
    }
    
    func isLiked(photo: Image, completion: @escaping (_ likes: Int) -> ()) {
        
    }
    
    func getLikeList(photo: Image, completion: @escaping (_ likes: Int) -> ()) {
        let likesGetList_photos = "https://api.vk.com/method/likes.getList?type=photo&owner_id=\(photo.ownerId!)&item_id=\(photo.id!)&access_token=\(Requests.token)&v=5.101"
        service?.getData(urlStr: likesGetList_photos, method: .get, body: nil, headers: nil, completion: { (likes: LikesList?, err) in
            completion((likes?.count)!)
        })
    }
    
    func getPhotosUrl() {
        if isLoading == false {
            isLoading = true
            let state = vc?.getViewModeState()
            var url: String = ""
            if state == 0 {
                url = "https://api.vk.com/method/photos.getAll?owner_id=62909394&offset=\(Requests.offset)&photo_sizes=1&count=30&access_token=\(Requests.token)&v=5.101"
            } else if state == 1 {
                url = "https://api.vk.com/method/photos.getAll?owner_id=62909394&offset=\(Requests.offset)&photo_sizes=1&count=2&access_token=\(Requests.token)&v=5.101"
            }
            service?.getData(urlStr: url, method: .get, body: nil, headers: nil, completion: { (response: Photos?, err) in
                if let response = response {
                    if state == 0 {
                        Requests.offset += 30
                    } else if state == 1 {
                        Requests.offset += 2
                    }
                    self.fetchDataSource(response: response)
                } else {
                    DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 5, execute: {
                        self.isLoading = false
                        self.getPhotosUrl()
                    })
                }
            })
        }
    }
}

private extension ImagePresenter {
    
    func getAccountInformation() {
        self.service?.getData(urlStr: Requests.profileInfo, method: .get, body: nil, headers: nil, completion: { (profile: ProfileInfo?, err) in
            self.vc?.setProfileInformation(profile: profile!)
        })
    }
    
    func getCountOfFriendsAndFolowers() {
        self.service?.getData(urlStr: Requests.friends_get, method: .get, body: nil, headers: nil, completion: { (account: Account?, err) in
            self.vc?.setFriends(friends: account!.followersCount!)
        })
        
        self.service?.getData(urlStr: Requests.users_getFollowers, method: .get, body: nil, headers: nil, completion: { (account: Account?, err) in
            self.vc?.setFollowers(followers: account!.followersCount!)
        })
    }
    
    func getAvatar() {
        downloadService?.downloadImage(image: Image(img: nil, url: Requests.avatarUrl, id: 22800848, ownerId: 228008), progress: { (progress) in
        }, completion: { (img, url) in
            self.vc?.loadAvatar(image: img)
        })
    }
    
    func fetchDataSource(response: Photos) {
        if let items = response.items {
            for item in items {
                if let sizes = item.sizes {
                    for size in sizes {
                        //if size.type == "z" {
                        images.append(Image(img: nil, url: size.url, id: item.id, ownerId: item.ownerId))
                        break
                        //}
                    }
                }
            }
            vc?.configureWithPhotos(images: images)
        }
    }
}
