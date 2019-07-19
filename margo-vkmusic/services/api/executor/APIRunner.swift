//
//  APIRunner.swift
//  simple
//
//  Created by Ivan Shpileuski on 5/29/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation

protocol APIRunnerProtocol  {
    func run(request: URLRequest, completion: @escaping (_ data: Data?, _ error: Error?) -> ())
    func runImageDataTask(request: URLRequest, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ())
}

class APIRunner: APIRunnerProtocol {
    func run(request: URLRequest, completion: @escaping (_ data: Data?, _ error: Error?) -> ()) {
        let session = URLSession.shared
        session.dataTask(with: request) { (data, res, error) in
            if let err = error {
                completion(nil, err)
            }
            if let data = data {
                completion(data, error)
            }
        }.resume()
    }
    
    func runImageDataTask(request: URLRequest, completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> ()) {
        let session = URLSession.shared
        session.dataTask(with: request) { (data, res, error) in
            if let err = error {
                completion(nil, res, err)
            }
            if let data = data {
                completion(data, res, error)
            }
        }.resume()
    }
}

