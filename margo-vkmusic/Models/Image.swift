//
//  Image.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/4/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit
import ObjectMapper

struct Photos {
    var count: Int?
    var items: [Item]?
}

extension Photos: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        self.count <- (map["count"])
        self.items <- (map["items"])
    }
}

struct Item {
    var id: Int?
    var sizes: [Size]?
}

extension Item: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        id <- (map["id"])
        sizes <- (map["sizes"])
    }
}

struct Size {
    var url: String?
    var type: String?
}

extension Size: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        url <- (map["url"])
        type <- (map["type"])
    }
}

struct Image {
    var img: UIImage?
    var url: String?
}

