//
//  APIService.swift
//  simple
//
//  Created by Ivan Shpileuski on 5/29/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit
import ObjectMapper


protocol APIServiceProtocol {
    func getData<T: Mappable>(urlStr: String, method: requestMethod, body: Data?, headers: Dictionary<String, String>?, completion: @escaping (_ response: T?, _ error: Error?) -> ())
    func getData<T: Mappable>(urlStr: String, method: requestMethod, body: Data?, headers: Dictionary<String, String>?, completion: @escaping (_ response: [T]?, _ error: Error?) -> ())
}

enum RequestError: Error {
    case invalidURL
    case invalidJSON
    case runError
    case parseError
    case apiError(error: VkApiRequestError)
    case badData
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
        case .badData:
            return NSLocalizedString("Bad data", comment: "Something wrong with request body")
        case .apiError(let error):
            return NSLocalizedString("Api error", comment: error.errorMessage ?? "Sorry, your request can't be processed")
        }
    }
}

class APIService {
    var builder: APIBuilderProtocol
    var runner: APIRunnerProtocol
    var parser: APIParserProtocol
    private let queue = DispatchQueue.global(qos: .background)
    init(builder: APIBuilder, runner: APIRunner, parser: APIParser) {
        self.builder = builder
        self.runner = runner
        self.parser = parser
    }
}

extension APIService: APIServiceProtocol {
    func getData<T: Mappable>(urlStr: String, method: requestMethod, body: Data? = nil,
                              headers: Dictionary<String, String>? = nil, completion: @escaping (_ outArray: T?, _ error: Error?) -> ()) {
        queue.async { [weak self] in
            var req: URLRequest?
            guard let strongSelf = self else { return }
            do {
                req = try strongSelf.builder.build(url: urlStr, method: method, body, headers)
            } catch {
                completion(nil, error)
                return
            }
            if let req = req {
                strongSelf.runner.run(request: req, completion: { (data, error) in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    do {
                        guard let data = data else { return }
                        if let response: T = try (strongSelf.parser.parse(data: data)) {
                            DispatchQueue.main.async {
                                completion(response, nil)
                            }
                        }
                    } catch {
                        DispatchQueue.main.async {
                            if let error = error as? VkApiRequestError {
                                completion(nil, error)
                            }
                        }
                    }
                })
            }
        }
    }
    
    func getData<T: Mappable>(urlStr: String, method: requestMethod, body: Data? = nil,
                              headers: Dictionary<String, String>? = nil, completion: @escaping (_ outArray: [T]?, _ error: Error?) -> ()) {
        queue.async { [weak self] in
            guard let strongSelf = self else { return }
            var req: URLRequest?
            do {
                req = try strongSelf.builder.build(url: urlStr, method: method, body, headers)
            } catch {
                completion(nil, error)
                return
            }
            if let req = req {
                strongSelf.runner.run(request: req, completion: { (data, error) in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    do {
                        guard let data = data,
                            let response: [T] = try (strongSelf.parser.parse(data: data))
                            else { return }
                        DispatchQueue.main.async {
                            completion(response, nil)
                        }
                    } catch {
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                })
            }
        }
    }
}
