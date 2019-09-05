//
//  APIParser.swift
//  simple
//
//  Created by Ivan Shpileuski on 5/29/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import ObjectMapper

protocol APIParserProtocol {
    func parse<T: Mappable>(data: Data) throws -> T?
    func parse<T: Mappable>(data: Data) throws -> Array<T>
}

class APIParser: APIParserProtocol {
    func parse<T: Mappable>(data: Data) throws -> T? {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            //print(json)
            guard let dictionary = json as? [String: Any] else {
                throw RequestError.invalidJSON
            }
            if let schema = dictionary["response"] as? Dictionary<String, Any> {
                if let model = Mapper<T>().map(JSON: schema) {
                    return model
                } else {
                    throw RequestError.parseError
                }
            } else if let error = dictionary["error"] as? Dictionary<String, Any> {
                print(error)
            } else {
                if let model = Mapper<T>().map(JSON: dictionary) {
                    return model
                } else {
                    throw RequestError.parseError
                }
            }
        } catch {
            throw RequestError.invalidJSON
        }
        return nil
    }
    
    func parse<T: Mappable>(data: Data) throws -> Array<T> {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else { fatalError() }
            guard let response = json["response"] as? [[String: Any]] else {
                throw RequestError.invalidJSON
            }
            //print(json)
            return Mapper<T>().mapArray(JSONArray: response)
        } catch {
            throw RequestError.parseError
        }
    }
}
