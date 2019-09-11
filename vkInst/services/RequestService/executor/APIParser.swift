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
            guard let dictionary = json as? [String: Any] else {
                throw RequestError.invalidJSON
            }
            print(json)
            if let schema = dictionary["response"] as? Dictionary<String, Any> {
                if let model = Mapper<T>().map(JSON: schema) {
                    return model
                } else {
                    throw RequestError.parseError
                }
            } else if let error = dictionary["error"] as? [String: Any] {
                if let model = Mapper<VkApiRequestError>().map(JSON: error) {
                    let err = RequestError.apiError(error: model)
                    throw err
                }
            } else {
                if let model = Mapper<T>().map(JSON: dictionary) {
                    return model
                } else {
                    throw RequestError.parseError
                }
            }
        } catch {
            throw error
        }
        return nil
    }
    
    
    func parse<T: Mappable>(data: Data) throws -> Array<T> {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else { fatalError() }
            guard let response = json["response"] as? [[String: Any]] else {
                throw RequestError.invalidJSON
            }
            return Mapper<T>().mapArray(JSONArray: response)
        } catch {
            throw RequestError.parseError
        }
    }
}
