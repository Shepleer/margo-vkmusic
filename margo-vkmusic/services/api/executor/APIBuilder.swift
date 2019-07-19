//
//  APIBuilder.swift
//  simple
//
//  Created by Ivan Shpileuski on 5/29/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation

enum requestMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol APIBuilderProtocol {
    func build(url: String, method: requestMethod, _ body: Dictionary<String, Any>?, _ headers: Dictionary<String, String>?) throws -> URLRequest
}

class APIBuilder: APIBuilderProtocol {
    func build(url: String, method: requestMethod, _ body: Dictionary<String, Any>? = nil, _ headers: Dictionary<String, String>? = nil) throws -> URLRequest {
        var req: URLRequest
        if let url = URL(string: url) {
            req = URLRequest(url: url)
            req.httpMethod = method.rawValue
            if let body = body {
                do {
                    req.httpBody = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
                } catch {
                    throw RequestError.invalidJSON
                }
            }
            if let headers = headers {
                headers.map { (key: String, value: String) -> () in
                    req.addValue(value, forHTTPHeaderField: key)
                }
            }
            return req
        } else {
            throw RequestError.invalidURL
        }
    }
}
