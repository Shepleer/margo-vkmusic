//
//  User.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 7/31/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit
import ObjectMapper

struct User {
    var id: Int?
    var firstName: String?
    var lastName: String?
    var avatarPhotoUrl: String?
    var screenName: String?
    var counters: Counters?
    var avatarImage: UIImage?
}

extension User: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        id <- (map["id"])
        firstName <- (map["first_name"])
        lastName <- (map["last_name"])
        avatarPhotoUrl <- (map["photo_100"])
        screenName <- (map["screen_name"])
        counters <- (map["counters"])
    }
}

struct Counters {
    var photos: Int?
    var friends: Int?
    var followers: Int?
}

extension Counters: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        photos <- (map["photos"])
        friends <- (map["friends"])
        followers <- (map["followers"])
    }
}
