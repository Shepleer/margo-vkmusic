//
//  Error.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 9/9/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import ObjectMapper

enum ErrorCode: Int {
    case captchaError = 14
    case authorizationError = 5
    
    
}

struct VkApiRequestError: Error  {
    var errorCode: Int?
    var errorMessage: String?
    var captchaSid: String?
    var captchaImgUrl: String?
    var url: String?
}

extension VkApiRequestError: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        errorCode <- (map["error_code"])
        errorMessage <- (map["error_msg"])
        if errorCode == 14 {
            captchaSid <- (map["captcha_sid"])
            captchaImgUrl <- (map["captcha_img"])
        }
    }
}
