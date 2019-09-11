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
    func refreshPageService()
}

class PageService {
    private var offset: Int = 0
    private var isLoading: Bool = false
    private var isAllLoaded: Bool = false
    var requestService: APIService
    
    private var userId = UserDefaults.standard.string(forKey: "userId") ?? "Token has expired"
    private var token = UserDefaults.standard.string(forKey: "accessToken") ?? "Token has expired"
    //private struct RequestConfigurations {
        //static let userId = UserDefaults.standard.string(forKey: "userId") ?? "Token has expired"
        //static let token = UserDefaults.standard.string(forKey: "accessToken") ?? "Token has expired"
    //}
    
    init(requestService: APIService) {
        self.requestService = requestService
    }
}

extension PageService: PageServiceProtocol {
    func nextFetch(completion: @escaping (_ photos: [Post]) -> ()) -> () {
        if isLoading || isAllLoaded {
            return
        }
        isLoading = true
        let url = "https://api.vk.com/method/wall.get?count=60&offset=\(offset)&extended=1&access_token=\(token)&v=5.101"
        requestService.getData(urlStr: url, method: .get, body: nil, headers: nil, completion: { [weak self] (response: PostResponse?, err) in
            if let strongSelf = self, let response = response, let count = response.count {
                strongSelf.offset += 60
                if count <= strongSelf.offset {
                    strongSelf.isAllLoaded = true
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
    
    func refreshPageService() {
        isLoading = false
        isAllLoaded = false
        offset = 0
    }
}
