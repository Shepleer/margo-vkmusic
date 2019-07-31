//
//  Account.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/1/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import ObjectMapper

struct Account {
    var followersCount: Int?
}

extension Account: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        self.followersCount <- (map["count"])
    }
}

struct ProfileInfo {
    var firstName: String?
    var lastName: String?
    var screenName: String?
    var homeTown: String?
}

extension ProfileInfo: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        self.firstName <- (map["first_name"])
        self.lastName <- (map["last_name"])
        self.screenName <- (map["screen_name"])
        self.homeTown <- (map["home_town"])
    }
}
