//
//  Group.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/6/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import ObjectMapper

struct Group {
    var id: Int?
    var firstName: String?
    var lastName: String?
    var screenName: String?
    var avatarImage: String?
}

extension Group: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        id <- (map["id"])
        firstName <- (map["first_name"])
        lastName <- (map["last_name"])
        screenName <- (map["screen_name"])
        avatarImage <- (map["photo_100"])
    }
}
