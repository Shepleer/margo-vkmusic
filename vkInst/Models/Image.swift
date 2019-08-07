//
//  Image.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/4/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit
import ObjectMapper

struct PhotosResponse {
    var count: Int?
    var images: [Image]?
}

extension PhotosResponse: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        count <- (map["count"])
        images <- (map["items"])
    }
}

struct Image {
    var img: UIImage?
    var url: String?
    var id: Int?
    var ownerId: Int?
    var isLiked: Bool?
    var likesCount: Int?
    var repostsCount: Int?
    var caption: String?
    var commentsCount: Int?
    var comments: [Comment]?
}

extension Image: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        url <- (map["sizes"], UrlTransform())
        id <- (map["id"])
        ownerId <- (map["owner_id"])
        isLiked <- (map["likes"], IsUserLikedTransform())
        likesCount <- (map["likes"], LikesCountTransform())
        repostsCount <- (map["reposts"], RepostsCountTransform())
        caption <- (map["text"])
    }
}

fileprivate struct RepostsCountTransform: TransformType {
    typealias Object = Int
    typealias JSON = [String: Any]
    
    func transformFromJSON(_ value: Any?) -> Int? {
        if let reposts = value as? [String: Any] {
            if let count = reposts["count"] as? Int {
                return count
            }
        }
        return nil
    }
    
    func transformToJSON(_ value: Int?) -> [String : Any]? {
        return nil
    }
}

fileprivate struct LikesCountTransform: TransformType {
    typealias Object = Int
    typealias JSON = [String: Any]
    
    func transformFromJSON(_ value: Any?) -> Int? {
        if let likes = value as? [String: Any] {
            if let count = likes["count"] as? Int {
                return count
            }
        }
        return nil
    }
    
    func transformToJSON(_ value: Int?) -> [String : Any]? {
        return nil
    }
}

fileprivate struct IsUserLikedTransform: TransformType {
    typealias Object = Bool
    typealias JSON = [String: Any]
    
    func transformFromJSON(_ value: Any?) -> Bool? {
        if let likes = value as? [String: Any] {
            if let isLiked = likes["user_likes"] as? Int {
                return isLiked == 1 ? true : false
            }
        }
        return nil
    }
    
    func transformToJSON(_ value: Bool?) -> [String : Any]? {
        return nil
    }
}

fileprivate struct UrlTransform: TransformType {
    typealias Object = String
    typealias JSON = [[String: Any]]
    
    func transformFromJSON(_ value: Any?) -> String? {
        if let items = value as? [[String: Any]] {
            for item in items {
                if let type = item["type"] as? String {
                    if type == "w" {
                        return item["url"] as? String
                    } else if type == "z" {
                        return item["url"] as? String
                    } else if type == "y" {
                        return item["url"] as? String
                    } else if type == "r" {
                        return item["url"] as? String
                    }
                }
            }
        }
        return nil
    }
    
    func transformToJSON(_ value: String?) -> [[String: Any]]? {
        return nil
    }
}

