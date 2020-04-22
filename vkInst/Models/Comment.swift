//
//  Comment.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/2/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import ObjectMapper

struct CommentsResponse {
    var comments: [Comment]?
    var count: Int?
    var profiles: [User]?
    var groups: [Group]?
}

extension CommentsResponse: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        comments <- (map["items"])
        count <- (map["count"])
        profiles <- (map["profiles"])
        groups <- (map["groups"])
    }
}

struct Comment {
    var id: Int?
    var fromId: Int?
    var date: Int?
    var text: String?
    var postId: Int?
    var name: String?
}

extension Comment: Mappable {
    init?(map: Map) {
        mapping(map: map)
    }
    
    mutating func mapping(map: Map) {
        id <- (map["id"])
        fromId <- (map["from_id"])
        date <- (map["date"])
        text <- (map["text"])
        postId <- (map["pid"])
    }
}

struct SendCommentResponse {
    var commentId: Int?
}

extension SendCommentResponse: Mappable {
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        commentId <- (map["comment_id"])
    }
}
