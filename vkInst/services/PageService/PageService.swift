//
//  PagingService.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/1/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation

protocol PageServiceProtocol {
    func nextFetch(completion: @escaping (_ photos: [Post]) -> ()) -> ()
    func fetchComplete()
    func checkIsAllLoaded() -> Bool
}

class PageService {
    private var offset: Int = 0
    private var isLoading: Bool = false
    private var isAllLoaded: Bool = false
    var requestService: APIService?
    private struct RequestConfigurations {
        static let userId = UserDefaults.standard.string(forKey: "userId")!
        static let token = UserDefaults.standard.string(forKey: "accessToken")!
    }
}

extension PageService: PageServiceProtocol {
    func nextFetch(completion: @escaping (_ photos: [Post]) -> ()) -> () {
        if isLoading || isAllLoaded {
            return
        }
        isLoading = true
        let url = "https://api.vk.com/method/wall.get?owner_id=454963921&count=60&offset=\(offset)&extended=1&access_token=\(RequestConfigurations.token)&v=5.101"
        requestService?.getData(urlStr: url, method: .get, body: nil, headers: nil, completion: { (response: PostResponse?, err) in
            if let response = response {
                self.offset += 60
                if response.count! <= self.offset {
                    self.isAllLoaded = true
                }
                guard let posts = response.items?.filter({ $0.photos?.isEmpty == false || $0.gifs?.isEmpty == false }) else { return }
                completion(posts)
            }
        })
    }
    
    func checkIsAllLoaded() -> Bool {
        return isAllLoaded
    }
    
    func fetchComplete() {
        isLoading = false
    }
}
