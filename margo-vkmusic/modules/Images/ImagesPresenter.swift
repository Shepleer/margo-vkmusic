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
    func loadImage(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage) -> ())
    func imagesDownloaded()
    func cancelDownload(image: Image)
}

class ImagePresenter: NSObject {
    weak var vc: ImagesViewControllerProtocol?
    var service: APIServiceProtocol?
    var downloadService: DownloadService?
    var images = [Image]()
    var isLoading = false
    
    private struct Requests {
        static let userId = UserDefaults.standard.string(forKey: "userId")!
        static let token = UserDefaults.standard.string(forKey: "accessToken")!
        static var offset = 0
        static let friends_get = "https://api.vk.com/method/friends.get?user_id=32707600&access_token=\(token)&v=5.101"
        static let users_getFollowers = "https://api.vk.com/method/users.getFollowers?user_id=32707600&access_token=\(token)&v=5.101"
        static let photos_getAll = "https://api.vk.com/method/photos.getAll?owner_id=32707600&access_token=\(token)&v=5.101"
        static let getAvatar = "https://sun2.beltelecom-by-minsk.userapi.com/c854216/v854216577/5f240/WIjKqVUoAuU.jpg"
    }
}

extension ImagePresenter: ImagePresenterProtocol {
    func viewDidLoad() {
        DispatchQueue.global().async {
            self.getAvatar()
            self.getPhotosUrl()
            self.getCountOfFriendsAndFolowers()
        }
    }
    
    func cancelDownload(image: Image) {
        downloadService?.cancelDownload(image: image)
    }
    
    func getCountOfFriendsAndFolowers() {
        DispatchQueue.global().async {
            self.service?.getData(urlStr: Requests.friends_get, method: .get, body: nil, headers: nil, completion: { (account: Account?, err) in
                self.vc?.setFriends(friends: account!.followersCount!)
            })
            self.service?.getData(urlStr: Requests.users_getFollowers, method: .get, body: nil, headers: nil, completion: { (account: Account?, err) in
                self.vc?.setFollowers(followers: account!.followersCount!)
            })
        }
    }
    
    func imagesDownloaded() {
        isLoading = false
    }
    
    func getAvatar() {
        downloadService?.downloadImage(image: Image(img: nil, url: "https://pp.userapi.com/c850632/v850632368/12f83a/F_KkO78daRs.jpg"), progress: { (progress) in
        }, completion: { (img) in
            self.vc?.loadAvatar(image: img)
        })
    }
    
    func loadImage(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage) -> ()) {
        DispatchQueue.global().sync {
            downloadService?.downloadImage(image: Image(img: nil, url: url), progress: progress, completion: completion)
        }
    }
    
    func fetchDataSource(response: Photos) {
        if let items = response.items {
            for item in items {
                if let sizes = item.sizes {
                    for size in sizes {
                        if size.type == "z" {
                            images.append(Image(img: nil, url: size.url))
                            break
                        }
                    }
                }
            }
        vc?.configureWithPhotos(images: images)
        }
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
                    self.fetchDataSource(response: response)
                    if state == 0 {
                        Requests.offset += 30
                    } else if state == 1 {
                        Requests.offset += 2
                    }
                    print(Requests.offset)
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
