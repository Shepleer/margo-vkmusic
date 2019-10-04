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
    func cancelDownload(image: Image)
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
    let queue = DispatchQueue.global(qos: .default)
}

extension DownloadService: DownloadServiceProtocol {
    func downloadMedia(url: String, type: MediaType, progress: @escaping DownloadProgress, completion: @escaping MediaLoadingCompletion) {
        queue.async { [weak self] in
            guard let self = self,
                let url = URL(string: url) else { return }
            let req = URLRequest(url: url)
            if let res = URLCache.shared.cachedResponse(for: req) {
                let data = res.data
                var img: UIImage? = nil
                if type == .image {
                    img = UIImage(data: data)
                } else if type == .gif {
                    img = UIImage.gif(data: data)
                }
                if let img = img {
                    completion(img, url.absoluteString)
                } else {
                    let strUrl = url.absoluteString
                    guard let task = self.session?.downloadTask(with: url) else { return }
                    self.activeDownloads[strUrl] = (completion, progress, task, type) as (MediaLoadingCompletion, DownloadProgress, Task, MediaType)
                    task.resume()
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let strUrl = url.absoluteString
                    guard let task = self.session?.downloadTask(with: url) else { return }
                    self.activeDownloads[strUrl] = (completion, progress, task, type) as (MediaLoadingCompletion, DownloadProgress, Task, MediaType)
                    task.resume()
                }
            }
        }
    }
    
    func cancelDownload(image: Image) {
        queue.async { [weak self] in
            guard let self = self,
                let url = image.url else { return }
            if let task = self.activeDownloads[url]?.task {
                task.cancel()
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.activeDownloads.removeValue(forKey: url)
                }
            }
        }
    }
    
    func invalidateSession() {
        activeDownloads.removeAll()
        session?.invalidateAndCancel()
    }
}

extension DownloadService: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            guard let absoluteUrl = downloadTask.originalRequest?.url?.absoluteString,
                let type = activeDownloads[absoluteUrl]?.type else { return }
            let data = try Data(contentsOf: location)
            var img: UIImage? = nil
            if type == .gif {
                img = UIImage.gif(data: data)
            } else if type == .image {
                img = UIImage(data: data)
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let req = downloadTask.originalRequest,
                       let img = img else { return }
                if let comp = self.activeDownloads[absoluteUrl]?.completion,
                    let response = downloadTask.response {
                        if URLCache.shared.cachedResponse(for: req) == nil {
                            URLCache.shared.storeCachedResponse(CachedURLResponse(response: response, data: data), for: req)
                        }
                        comp(img, absoluteUrl)
                        self.activeDownloads.removeValue(forKey: absoluteUrl)
                    
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        queue.async { [weak self] in
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            let url = downloadTask.originalRequest?.url
            DispatchQueue.main.async { [weak self] in
                guard let self = self, let absoluteUrl = url?.absoluteString else { return }
                if let comp = self.activeDownloads[absoluteUrl]?.progress {
                    comp(progress)
                }
            }
        }
    }
}
