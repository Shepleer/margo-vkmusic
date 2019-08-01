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
    func imagesDownloaded()
    func cancelDownload(image: Image)
    func loadImage(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ())
    func setLike(photo: Image, completion: @escaping (_ likes: Int) -> ())
    func getLikeList(photo: Image, completion: @escaping (_ likes: Int) -> ())
    func fetchLikeList(photo: Image, setLikesCount: @escaping (_ likes: Int) -> (), setLikeButtonState: @escaping (_ isLiked: Bool) -> ())
    func removeLike(photo: Image, completion: @escaping (_ likes: Int) -> ())
    func nextFetch()
}

class ImagePresenter: NSObject {
    weak var vc: ImagesViewControllerProtocol?
    var service: APIServiceProtocol?
    var downloadService: DownloadService?
    var userService: UserSerice?
    var pageService: PageServiceProtocol?
    var router: ImagesRouterProtocol?
    
    private struct Requests {
        static let userId = UserDefaults.standard.string(forKey: "userId")!
        static let token = UserDefaults.standard.string(forKey: "accessToken")!
        static var offset = 0
        static let photos_getAll = "https://api.vk.com/method/photos.getAll?owner_id=454963921&access_token=\(token)&v=5.101"
        static let avatarUrl = "https://pp.userapi.com/c850632/v850632368/12f83a/F_KkO78daRs.jpg"
        static let ownerId = 00
        static let id = 00
        let likesAdd_photos = "https://api.vk.com/method/likes.add?type=photo&owner_id=\(ownerId)&item_id=\(id)&access_token=\(token)&v=5.101"
        let likesDelete_photos = "https://api.vk.com/method/likes.delete?type=photo&owner_id=\(ownerId)&item_id=\(id)&access_token=\(token)&v=5.101"
        let likesIsLiked = "https://api.vk.com/method/likes.isLiked?user_id=\(Requests.userId)&type=photo&owner_id=\(ownerId)&item_id=\(id)&access_token=\(token)&v=5.101"
    }
}

extension ImagePresenter: ImagePresenterProtocol {
    func viewDidLoad() {
        getProfile()
    }
    
    func cancelDownload(image: Image) {
        downloadService?.cancelDownload(image: image)
    }
    
    func imagesDownloaded() {
        pageService?.fetchComplete()
    }
    
    func loadImage(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ()) {
        downloadService?.downloadImage(url: url, progress: progress, completion: completion)
    }
    
    func setLike(photo: Image, completion: @escaping (_ likes: Int) -> ()) {
        userService?.setLike(photo: photo, completion: completion)
    }
    
    func removeLike(photo: Image, completion: @escaping (_ likes: Int) -> ()) {
        userService?.removeLike(photo: photo, completion: completion)
    }
    
    func fetchLikeList(photo: Image, setLikesCount: @escaping (_ likes: Int) -> (), setLikeButtonState: @escaping (_ isLiked: Bool) -> ()) {
        userService?.fetchLikeList(photo: photo, setLikesCount: setLikesCount, setLikeButtonState: setLikeButtonState)
    }
    
    func getLikeList(photo: Image, completion: @escaping (_ likes: Int) -> ()) {
        let likesGetList_photos = "https://api.vk.com/method/likes.getList?type=photo&owner_id=\(photo.ownerId!)&item_id=\(photo.id!)&access_token=\(Requests.token)&v=5.101"
        service?.getData(urlStr: likesGetList_photos, method: .get, body: nil, headers: nil, completion: { (likes: LikesList?, err) in
            completion((likes?.count)!)
        })
    }
    
    func nextFetch() {
        pageService?.nextFetch(completion: { (images) in
            self.vc?.configureWithPhotos(images: images)
        })
    }
}

private extension ImagePresenter {
    func getProfile() {
        userService?.getUserProfileInfo(completion: { (user) in
            self.downloadService?.downloadImage(url: user.avatarPhotoUrl!, progress: { (progress) in
            }, completion: { (img, err) in
                self.vc?.loadAvatar(image: img)
            })
            self.vc?.setProfileData(user: user)
        })
    }
}
