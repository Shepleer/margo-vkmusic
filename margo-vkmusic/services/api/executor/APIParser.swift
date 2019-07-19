//
//  APIParser.swift
//  simple
//
//  Created by Ivan Shpileuski on 5/29/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol APIParserProtocol {
    func parse(data: Data)throws -> Dictionary<String, Any>
    func parseImage(data: Data)throws -> UIImage
}

class APIParser: APIParserProtocol {
    func parse(data: Data)throws -> Dictionary<String, Any> {
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: [])
            if let out = json as? [String: Any] {
                return out
            } else {
                throw RequestError.invalidJSON
            }
        }catch {
            throw error
        }
    }
    
    func parseImage(data: Data) throws -> UIImage {
        return UIImage(data: data)!
        if let image =  UIImage(data: data) {
            return image
        } else {
            throw RequestError.parseError
        }
    }
}
