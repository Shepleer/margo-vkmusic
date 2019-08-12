//
//  Like.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/30/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import ObjectMapper

struct LikesSet {
    var likes: Int?
}

extension LikesSet: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        likes <- (map["likes"])
    }
}
