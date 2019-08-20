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
    var url: String?
    var size: Int?
}

extension Gif: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        url <- (map["url"])
        size <- (map["size"])
    }
}
