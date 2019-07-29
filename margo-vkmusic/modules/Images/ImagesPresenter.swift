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
    }
}

extension ImagePresenter: ImagePresenterProtocol {
    func viewDidLoad() {
        self.getAvatar()
        self.getPhotosUrl()
        self.getCountOfFriendsAndFolowers()
    }
    
    func cancelDownload(image: Image) {
        downloadService?.cancelDownload(image: image)
    }
    
    func imagesDownloaded() {
        isLoading = false
    }
    
    func loadImage(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ()) {
        downloadService?.downloadImage(image: Image(img: nil, url: url), progress: progress, completion: completion)
    }
    
    func getPhotosUrl() {
        if isLoading == false {
            isLoading = true
            let state = vc?.getViewModeState()
            var url: String = ""
            if state == 0 {
                url = "https://api.vk.com/method/photos.getAll?owner_id=150261846&offset=\(Requests.offset)&photo_sizes=1&count=30&access_token=\(Requests.token)&v=5.101"
            } else if state == 1 {
                url = "https://api.vk.com/method/photos.getAll?owner_id=150261846&offset=\(Requests.offset)&photo_sizes=1&count=2&access_token=\(Requests.token)&v=5.101"
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
    func getCountOfFriendsAndFolowers() {
        self.service?.getData(urlStr: Requests.friends_get, method: .get, body: nil, headers: nil, completion: { (account: Account?, err) in
            self.vc?.setFriends(friends: account!.followersCount!)
        })
        
        self.service?.getData(urlStr: Requests.users_getFollowers, method: .get, body: nil, headers: nil, completion: { (account: Account?, err) in
            self.vc?.setFollowers(followers: account!.followersCount!)
        })
    }
    
    func getAvatar() {
        downloadService?.downloadImage(image: Image(img: nil, url: Requests.avatarUrl), progress: { (progress) in
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
                        images.append(Image(img: nil, url: size.url))
                        break
                        //}
                    }
                }
            }
            vc?.configureWithPhotos(images: images)
        }
    }
}
