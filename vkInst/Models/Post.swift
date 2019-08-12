//
//  Post.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/8/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import ObjectMapper

struct PostResponse {
    var count: Int?
    var items: [Post]?
}

extension PostResponse: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        count <- (map["count"])
        items <- (map["items"])
    }
}

struct Post {
    var id: Int?
    var ownerId: Int?
    var fromId: Int?
    var createdBy: Int?
    var date: Int?
    var text: String?
    var friendsOnly: Bool?
    var commentsCount: Int?
    var likesCount: Int?
    var isUserLikes: Bool?
    var repostCount: Int?
    var isUserReposted: Bool?
    var viewsCount: Int?
    var signerId: Int?
    var markedAsAds: Bool?
    var isFavorite: Bool?
    //var profiles: [User]?
    //var groups: [Group]?
    var photos: [Image]?
}

extension Post: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        id <- (map["id"])
        ownerId <- (map["owner_id"])
        fromId <- (map["from_id"])
        createdBy <- (map["created_by"])
        date <- (map["date"])
        text <- (map["text"])
        friendsOnly <- (map["friends_only"], IntToBoolTrasform())
        commentsCount <- (map["comments"], CountTransform())
        likesCount <- (map["likes"], CountTransform())
        isUserLikes <- (map["likes"], IsUserLikedTransform())
        repostCount <- (map["reposts"], CountTransform())
        isUserReposted <- (map["reposts"], IsUserRepostedTransform())
        viewsCount <- (map["views"], CountTransform())
        signerId <- (map["signer_id"])
        markedAsAds <- (map["marked_as_ads"], IntToBoolTrasform())
        isFavorite <- (map["is_favorite"])
        //profiles <- (map["profiles"])
        //groups <- (map["groups"])
        if map.JSON["copy_history"] == nil {
            photos <- (map["attachments"], AttachmentsTransform())
        } else {
            photos <- (map["copy_history"], CopyHistoryTransform())
        }
    }
}

fileprivate struct AttachmentsTransform: TransformType {
    typealias Object = [Image]
    typealias JSON = [String: Any]
    
    func transformFromJSON(_ value: Any?) -> [Image]? {
        var photos = [Image]()
        if let attachments = value as? [[String: Any]] {
            for item in attachments {
                if let photo = item["photo"] as? [String: Any] {
                    if let img = Image.init(map: Map(mappingType: .fromJSON, JSON: photo)) {
                        photos.append(img)
                    }
                }
            }
        }
        return photos
    }
    
    func transformToJSON(_ value: [Image]?) -> [String : Any]? {
        return nil
    }
}

fileprivate struct CopyHistoryTransform: TransformType {
    typealias Object = [Image]
    typealias JSON = [[String: Any]]
    
    func transformFromJSON(_ value: Any?) -> [Image]? {
        var photos = [Image]()
        if let history = value as? [[String: Any]] {
            if let attachments = history[0]["attachments"] as? [[String: Any]] {
                for item in attachments {
                    if let photo = item["photo"] as? [String: Any] {
                        if let img = Image.init(map: Map(mappingType: .fromJSON, JSON: photo)) {
                            photos.append(img)
                        }
                    }
                }
            }
        }
        return photos
    }
    
    func transformToJSON(_ value: [Image]?) -> [[String : Any]]? {
        return nil
    }
}
