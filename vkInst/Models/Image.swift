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
    }
    
    mutating func mapping(map: Map) {
        count <- (map["count"])
        images <- (map["items"])
    }
}

struct Image {
    var id: Int?
    var img: UIImage?
    var accessKey: String?
    var url: String?
    var albumId: Int?
    var ownerId: Int?
    var caption: String?
}

extension Image: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        accessKey <- (map["access_key"])
        if map["ext"].value() == "jpg" {
            url <- (map["url"])
        } else {
            url <- (map["sizes"], UrlTransform())
        }
        id <- (map["id"])
        albumId <- (map["album_id"])
        ownerId <- (map["owner_id"])
        caption <- (map["text"])
    }
}

fileprivate struct UrlTransform: TransformType {
    typealias Object = String
    typealias JSON = [[String: Any]]
    
    func transformFromJSON(_ value: Any?) -> String? {
        if let items = value as? [[String: Any]] {
            let needTypes = ["z", "w", "y", "x", "r"]
            for needType in needTypes {
                for item in items {
                    if let type = item["type"] as? String {
                        if type == needType {
                            return item["url"] as? String
                        }
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

