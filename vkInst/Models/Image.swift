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
}

extension Image: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        url <- (map["sizes"], UrlTransform())
        id <- (map["id"])
        ownerId <- (map["owner_id"])
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

