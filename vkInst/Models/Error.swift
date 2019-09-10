//
//  Error.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 9/9/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import ObjectMapper

struct VkApiRequestError: Error  {
    var errorCode: Int?
    var errorMessage: String?
}

extension VkApiRequestError: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        errorCode <- (map["error_code"])
        errorMessage <- (map["error_msg"])
    }
}
