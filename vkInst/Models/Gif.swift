//
//  Gif.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/12/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import ObjectMapper

struct Gif {
    var gif: UIImage?
    var preview: UIImage?
    var url: String?
    var size: Int?
    var previewUrl: String?
}

extension Gif: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        url <- (map["url"])
        size <- (map["size"])
        previewUrl <- (map["preview"], previewUrlTransform())
    }
}

fileprivate struct previewUrlTransform: TransformType {
    typealias Object = String
    
    typealias JSON = [String: Any]
    
    func transformFromJSON(_ value: Any?) -> String? {
        guard let value = value as? [String: Any] else { return nil }
        guard let photo = value["photo"] as? [String: Any] else { return nil }
        if let items = photo["sizes"] as? [[String: Any]] {
            let needTypes = ["z", "w", "y", "r", "o", "m"]
            for needType in needTypes {
                for item in items {
                    if let type = item["type"] as? String {
                        if type == needType {
                            return item["src"] as? String
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func transformToJSON(_ value: String?) -> [String : Any]? {
        return nil
    }
}
