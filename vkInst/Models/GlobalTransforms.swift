//
//  GlobalTransforms.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/8/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import ObjectMapper

struct CountTransform: TransformType {
    typealias Object = Int
    typealias JSON = [String: Any]
    
    func transformFromJSON(_ value: Any?) -> Int? {
        if let object = value as? [String: Any] {
            if let count = object["count"] as? Int {
                return count
            }
        }
        return nil
    }
    
    func transformToJSON(_ value: Int?) -> [String : Any]? {
        return nil
    }
}

struct IsUserLikedTransform: TransformType {
    typealias Object = Bool
    typealias JSON = [String: Any]
    
    func transformFromJSON(_ value: Any?) -> Bool? {
        if let likes = value as? [String: Any] {
            if let isLiked = likes["user_likes"] as? Int {
                return isLiked == 1 ? true : false
            }
        }
        return nil
    }
    
    func transformToJSON(_ value: Bool?) -> [String : Any]? {
        return nil
    }
}

struct IsUserRepostedTransform: TransformType {
    typealias Object = Bool
    typealias JSON = [String: Any]
    
    func transformFromJSON(_ value: Any?) -> Bool? {
        if let reposts = value as? [String: Any] {
            if let isReposted = reposts["user_reposted"] as? Int {
                return isReposted == 1 ? true : false
            }
        }
        return nil
    }
    
    func transformToJSON(_ value: Bool?) -> [String : Any]? {
        return nil
    }
}

struct IntToBoolTrasform: TransformType {
    typealias Object = Bool
    typealias JSON = [String: Any]
    
    func transformFromJSON(_ value: Any?) -> Bool? {
        if let value = value as? Int {
            return value == 1 ? true : false
        }        
        return nil
    }
    
    func transformToJSON(_ value: Bool?) -> [String : Any]? {
        return nil
    }
}
