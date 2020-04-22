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
    func refreshPagination()
}

class CommentsPageService {
    private var offset = 0
    private var isLoading = false
    private var isAllLoaded = false
    var requestService: APIService
    private var userId = UserDefaults.standard.string(forKey: "userId") ?? "Token has expired"
    private var token = UserDefaults.standard.string(forKey: "accessToken") ?? "Token has expired"
    private struct RequestConfigurations {
        static let offsetMultiplier = 20
        static let fetchCommentsTemplateUrl = "https://api.vk.com/method/wall.getComments?owner_id=[ownerId]&post_id=[postId]&need_likes=1&offset=[offset]&count=20&sort=asc&thread_items_count=10&preview_lenght=0&extended=1&access_token=[token]&v=5.101"
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
        let url = RequestConfigurations.fetchCommentsTemplateUrl
                    .replacingOccurrences(of: "[ownerId]", with: "\(ownerId)")
                    .replacingOccurrences(of: "[postId]", with: "\(postId)")
                    .replacingOccurrences(of: "[offset]", with: "\(offset)")
                    .replacingOccurrences(of: "[token]", with: token)
        requestService.getData(urlStr: url, method: .get, body: nil, headers: nil, completion: { [weak self] (response: CommentsResponse?, err) in
            if let self = self, let count = response?.count, let response = response {
                self.offset += RequestConfigurations.offsetMultiplier
                if count <= self.offset {
                    self.isAllLoaded = true
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
    
    func refreshPagination() {
        offset = 0
        isLoading = false
        isAllLoaded = false
    }
}
