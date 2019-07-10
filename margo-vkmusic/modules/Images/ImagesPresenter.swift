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
    func loadImage(url: String, complection: @escaping (_ img: UIImage?, _ response: URLResponse?, _ error: Error?) -> ())
}

class ImagePresenter {
    weak var vc: ImagesViewControllerProtocol?
    var service: APIServiceProtocol?
    var images = [Image]()
    
    private struct Requests {
        static let userId = UserDefaults.standard.string(forKey: "userId")!
        static let token = UserDefaults.standard.string(forKey: "accessToken")!
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
    
    func getAvatar() {
        service?.getImage(url: Requests.getAvatar, method: .get, body: nil, headers: nil, completion: { (image, res, err) in
            self.vc?.loadAvatar(image: image!)
        })
    }
    
    func loadImage(url: String, complection: @escaping (_ img: UIImage?, _ response: URLResponse?, _ error: Error?) -> ()) {
        service?.getImage(url: url, method: .get, body: nil, headers: nil, completion: { (img, res, err) in
            complection(img, res, err)
        })
    }
    
    func parseImagesUrl(json: Dictionary<String, Any>) {
        let schema = json["response"]! as! Dictionary<String, Any>
        let items = schema["items"] as! Array<Dictionary<String, Any>>
        for item in items {
            let sizes = item["sizes"] as! Array<Dictionary<String, Any>>
            for photo in sizes {
                if photo["width"] as! Int >= 130 && photo["height"] as! Int >= 130 {

                        self.images.append(Image(img: nil, url: (photo["url"] as! String)))
                        vc?.configureWithPhotos()
                    break
                }
            }
        }
    }
    
    func getAllPhotos() {
        service?.getData(urlStr: Requests.photos_getAll, method: .get, body: nil, headers: nil, completion: { (response, err) in
            if let response = response {
                self.parseImagesUrl(json: response)
            }
        })
    }
}
