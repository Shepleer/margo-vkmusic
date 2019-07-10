//
//  APIService.swift
//  simple
//
//  Created by Ivan Shpileuski on 5/29/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol APIServiceProtocol {
    func getData(urlStr: String, method: requestMethod, body: Dictionary<String, Any>?, headers: Dictionary<String, String>?, completion: @escaping (_ outDictionary: Dictionary<String, Any>?, _ error: Error?) -> ())
    func getImage(url: String, method: requestMethod, body: Dictionary<String, Any>?, headers: Dictionary<String, String>?, completion: @escaping (_ responseImage: UIImage?, _ response: URLResponse?, _ error: Error?) -> ())
}

enum RequestError: Error {
    case invalidURL
    case invalidJSON
    case runError
    case parseError
}

extension RequestError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid url", comment: "Invalid URL")
        case .runError:
            return NSLocalizedString("Not found", comment: "Bad connection or wrong url")
        case .invalidJSON:
            return NSLocalizedString("Wrong JSON", comment: "Wrong JSON")
        case .parseError:
            return NSLocalizedString("Parse error", comment: "Check response data")
        }
    }
}

class APIService: APIServiceProtocol {
    var builder: APIBuilderProtocol?
    var runner: APIRunnerProtocol?
    var parser: APIParserProtocol?
    
    let queue = DispatchQueue.global(qos: .background)
    func getData(urlStr: String, method: requestMethod, body: Dictionary<String, Any>? = nil, headers: Dictionary<String, String>? = nil, completion: @escaping (_ outDictionary: Dictionary<String, Any>?, _ error: Error?) -> ()) {
        queue.async {
            var req: URLRequest?
            do {
                req = try (self.builder?.build(url: urlStr, method: method, body, headers))!
            } catch {
                completion(nil, error)
                return
            }
            self.runner?.run(request: req!, completion: { (data, error) in
                if let error = error {
                    completion(nil, error)
                    return
                }
                do {
                    let outDictionary = try self.parser?.parse(data: data!)
                    DispatchQueue.main.async {
                        completion(outDictionary, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            })
        }
    }
    
    func getImage(url: String, method: requestMethod, body: Dictionary<String, Any>? = nil, headers: Dictionary<String, String>? = nil, completion: @escaping (_ responseImage: UIImage?, _ response: URLResponse?, _ error: Error?) -> ()) {
        queue.async {
            var request: URLRequest?
            do {
                request = try (self.builder?.build(url: url, method: method, body, headers))!
            } catch {
                completion(nil, nil, error)
                return
            }
            self.runner?.runImageDataTask(request: request!, completion: { (data, res, err) in
                if let error = err {
                    completion(nil, res, error)
                    return
                }
                do {
                    let image = try (self.parser?.parseImage(data: data!))
                    DispatchQueue.main.async {
                        completion(image, res, nil)
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(nil, res, error)
                    }
                }
            })
        }
    }
    
}
