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
    func build(url: String, method: requestMethod, _ body: Data?, _ headers: Dictionary<String, String>?) throws -> URLRequest
}

class APIBuilder: APIBuilderProtocol {
    func build(url: String, method: requestMethod, _ body: Data? = nil, _ headers: Dictionary<String, String>? = nil) throws -> URLRequest {
        var req: URLRequest
        guard let url = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { throw RequestError.invalidURL }
        if let url = URL(string: url) {
            req = URLRequest(url: url)
            req.httpMethod = method.rawValue
            if let body = body {
                req.httpBody = body
            }
            if let headers = headers {
                _ = headers.map { (key: String, value: String) -> () in
                    req.addValue(value, forHTTPHeaderField: key)
                }
            }
            return req
        } else {
            throw RequestError.invalidURL
        }
    }
}
