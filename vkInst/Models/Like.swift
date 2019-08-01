//
//  Like.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/30/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import ObjectMapper

struct Like {
    var liked: Int?
    var copied: Int?
}

extension Like: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        liked <- (map["liked"])
        copied <- (map["copied"])
    }
}

struct LikesSet {
    var likes: Int?
}

extension LikesSet: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        likes <- (map["likes"])
    }
}

struct LikesList {
    var count: Int?
}

extension LikesList: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        count <- (map["count"])
    }
}
