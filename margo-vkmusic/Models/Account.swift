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
