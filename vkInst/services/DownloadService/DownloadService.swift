//
//  DownloadService.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/16/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

typealias LoadingCompletion = ((_ image: UIImage) -> ())
typealias MediaLoadingCompletion = ((_ download: UIImage, _ url: String) -> ())
typealias DownloadProgress = ((_ progress: Float) -> ())
typealias Task = URLSessionDownloadTask
typealias TaskCompletion = (completion: MediaLoadingCompletion, progress: DownloadProgress, task: Task, type: MediaType)
typealias Downloads = [String: TaskCompletion]

protocol DownloadServiceProtocol: class {
    func cancelDownload(url: String)
    func invalidateSession()
    func downloadMedia(url: String, type: MediaType, progress: @escaping DownloadProgress, completion: @escaping MediaLoadingCompletion)
}

enum MediaType {
    case image
    case gif
}

class DownloadService: NSObject {
    private var activeDownloads: Downloads = [:]
    var session: URLSession? = nil
    let queue = DispatchQueue.global(qos: .background)
}

extension DownloadService: DownloadServiceProtocol {
    func downloadMedia(url: String, type: MediaType, progress: @escaping DownloadProgress, completion: @escaping MediaLoadingCompletion) {
        queue.async { [weak self] in
            guard let self = self,
                let request = self.buildRequest(with: url)
                else { return }
            
            if let image = self.getCachedResponse(for: request, type: type) {
                DispatchQueue.main.async {
                    completion(image, url)
                    return
                }
            }
            guard let task = self.session?.downloadTask(with: request) else { return }
            DispatchQueue.main.async {
                self.activeDownloads[url] = (completion, progress, task, type) as TaskCompletion
            }
            task.resume()
        }
    }
    
    func cancelDownload(url: String) {
        queue.async { [weak self] in
            guard let self = self,
                let task = self.activeDownloads[url]?.task
                else { return }
            task.cancel()
            self.activeDownloads.removeValue(forKey: url)
        }
    }
    
    func invalidateSession() {
        activeDownloads.removeAll()
        session?.invalidateAndCancel()
    }
}

extension DownloadService: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        queue.sync { [weak self] in
            do {
                guard let self = self,
                    let urlLiteral = downloadTask.originalRequest?.url?.absoluteString,
                    let request = downloadTask.originalRequest,
                    let type = self.activeDownloads[urlLiteral]?.type
                    else { return }
                let data = try Data(contentsOf: location)
                guard let image = self.createMediaFile(with: type, data: data),
                    let completion = self.activeDownloads[urlLiteral]?.completion,
                    let response = downloadTask.response
                    else { return }
                completion(image, urlLiteral)
                self.storeMediaFile(with: request, response: response, data: data)
                DispatchQueue.main.async {
                    self.activeDownloads.removeValue(forKey: urlLiteral)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        queue.async { [weak self] in
            guard let self = self,
                let urlLiteral = downloadTask.originalRequest?.url?.absoluteString
                else { return }
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            self.sendProgress(on: urlLiteral, progress: progress)
        }
    }
}

private extension DownloadService {
    func buildRequest(with urlLiteral: String) -> URLRequest? {
        guard let url = URL(string: urlLiteral) else { return nil }
        let request = URLRequest(url: url)
        return request
    }
    
    func getCachedResponse(for request: URLRequest, type: MediaType) -> UIImage? {
            guard let response = URLCache.shared.cachedResponse(for: request) else { return nil }
            let data = response.data
            return createMediaFile(with: type, data: data)
    }
    
    func createMediaFile(with type: MediaType, data: Data) -> UIImage? {
        switch type {
        case .gif:
            return UIImage(data: data)
        case .image:
            return UIImage.gif(data: data)
        }
    }
    
    func sendProgress(on urlLiteral: String, progress: Float) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                let progressCompletion = self.activeDownloads[urlLiteral]?.progress
                else { return }
            progressCompletion(progress)
        }
    }
    
    func storeMediaFile(with request: URLRequest, response: URLResponse, data: Data) {
        queue.sync {
            if URLCache.shared.cachedResponse(for: request) == nil {
                let cachedUrlResponse = CachedURLResponse(response: response, data: data)
                URLCache.shared.storeCachedResponse(cachedUrlResponse, for: request)
            }
        }
    }
}
