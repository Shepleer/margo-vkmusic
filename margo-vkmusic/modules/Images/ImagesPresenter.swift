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
    func getCountOfCells() -> Int
    func getImage(indexPath: IndexPath) -> Image
    func getAllPhotos()
    func getAvatar()
    func loadImage(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage) -> ())
    func imagesDownloaded()
    func configureDataSource(images: [Image])
    func cancelDownload(image: Image)
    var downloadService: DownloadService? { get }
    
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
            self.getAllPhotos()
            self.getCountOfFriendsAndFolowers()
        }
    }
    
    func cancelDownload(image: Image) {
        downloadService?.cancelDownload(image: image)
    }
    
    func configureDataSource(images: [Image]) {
        self.images = images
    }
    
    func getCountOfCells() -> Int {
        return images.count
    }
    
    func getImage(indexPath: IndexPath) -> Image {
        return images[indexPath.row]
    }
    
    func getCountOfFriendsAndFolowers() {
        DispatchQueue.global().async {
            self.service?.getData(urlStr: Requests.friends_get, method: .get, body: nil, headers: nil, completion: { (response, err) in
                let res = response!["response"] as! Dictionary<String, Any>
                self.vc?.setFriends(friends: res["count"] as! Int)
            })
            self.service?.getData(urlStr: Requests.users_getFollowers, method: .get, body: nil, headers: nil, completion: { (response, err) in
                let res = response!["response"] as! Dictionary<String, Any>
                self.vc?.setFollowers(followers: res["count"] as! Int)
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
    
    func parseImagesUrl(json: Dictionary<String, Any>) {
        if let schema = json["response"] as? Dictionary<String, Any> {
            let items = schema["items"] as! Array<Dictionary<String, Any>>
            for item in items {
                let sizes = item["sizes"] as! Array<Dictionary<String, Any>>
                for photo in sizes {
                    if photo["width"] as! Int >= 130 && photo["height"] as! Int >= 130 {
                        DispatchQueue.main.async {
                            self.images.append(Image(img: nil, url: (photo["url"] as! String)))
                            self.vc?.configureWithPhotos(images: self.images)
                        }
                        break
                    }
                }
            }
        } else {
            print(json)
            //5e+9 == 5 sec
            
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 5) {
                self.getAllPhotos()
            }
        }
    }
    
    func getAllPhotos() {
        if isLoading == false {
            isLoading = true
            let url = "https://api.vk.com/method/photos.getAll?owner_id=32707600&offset=\(Requests.offset)&count=30&access_token=\(Requests.token)&v=5.101"
            service?.getData(urlStr: url, method: .get, body: nil, headers: nil, completion: { (response, err) in
                if let response = response {
                    self.parseImagesUrl(json: response)
                    Requests.offset += 30
                }
            })
        }
    }
}
