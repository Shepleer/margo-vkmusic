//
//  UploadServer.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/13/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import ObjectMapper

struct UploadServer {
    var albumId: Int?
    var userId: Int?
    var uploadUrl: String?
}

extension UploadServer: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        uploadUrl <- (map["upload_url"])
        albumId <- (map["album_id"])
        userId <- (map["user_id"])
    }
}

struct UploadServerPhotoResponse {
    var server: Int?
    var photo: String?
    var hash: String?
}

extension UploadServerPhotoResponse: Mappable {
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        server <- (map["server"])
        photo <- (map["photo"])
        hash <- (map["hash"])
    }
}




