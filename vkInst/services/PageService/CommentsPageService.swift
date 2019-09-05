//
//  CommentsPageService].swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/2/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation

protocol CommentsPageServiceProtocol {
    func nextFetch(postId: Int, ownerId: Int, completion: @escaping (_ comments: [Comment], _ profiles: [User], _ groups: [Group]) -> ())
    func fetchComplete()
}

class CommentsPageService {
    private var offset = 0
    private var isLoading = false
    private var isAllLoaded = false
    var requestService: APIService
    private struct RequestConfigurations {
        static let userId = UserDefaults.standard.string(forKey: "userId")!
        static let token = UserDefaults.standard.string(forKey: "accessToken")!
    }
    
    init(requestService: APIService) {
        self.requestService = requestService
    }
}

extension CommentsPageService: CommentsPageServiceProtocol {
    func nextFetch(postId: Int, ownerId: Int, completion: @escaping (_ comments: [Comment], _ profiles: [User], _ groups: [Group]) -> ()) {
        if isLoading || isAllLoaded {
            return
        }
        isLoading = true
        let url = "https://api.vk.com/method/wall.getComments?owner_id=\(ownerId)&post_id=\(postId)&need_likes=1&offset=0&count=20&sort=asc&thread_items_count=10&preview_lenght=0&extended=1&access_token=\(RequestConfigurations.token)&v=5.101"
        requestService.getData(urlStr: url, method: .get, body: nil, headers: nil, completion: { [weak self] (response: CommentsResponse?, err) in
            if let strongSelf = self, let count = response?.count, let response = response {
                strongSelf.offset += 20
                if count <= strongSelf.offset {
                    strongSelf.isAllLoaded = true
                }
                guard let comments = response.comments,
                    let profiles = response.profiles,
                    let groups = response.groups else { return }
                completion(comments, profiles, groups)
            }
        })
    }
    
    func fetchComplete() {
        isLoading = false
    }
}
