//
//  DownloadService.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/16/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

typealias LoadingCompletion = ((_ image: UIImage) -> ())
typealias PhotoLoadingCompletion = ((_ download: UIImage, _ url: String) -> ())
typealias DownloadProgress = ((_ progress: Float) -> ())
typealias Task = URLSessionDownloadTask
typealias TaskCompletion = (completion: PhotoLoadingCompletion, progress: DownloadProgress, task: Task)
typealias Downloads = [String: TaskCompletion]

protocol DownloadServiceProtocol: class {
    func downloadImage(url: String, progress: @escaping DownloadProgress, completion: @escaping PhotoLoadingCompletion)
    func downloadGif(url: String, progress: @escaping DownloadProgress, completion: @escaping PhotoLoadingCompletion)
    func cancelDownload(image: Image)
    func invalidateSession()
}


class DownloadService: NSObject {
    private var activeDownloads: Downloads = [:]
    var session: URLSession? = nil
    let queue = DispatchQueue(label: "download_queue")
}


extension DownloadService: DownloadServiceProtocol {
    func downloadImage(url: String, progress: @escaping DownloadProgress, completion: @escaping PhotoLoadingCompletion) {
        queue.sync { [weak self] in
            guard let self = self, let url = URL(string: url) else { return }
            let req = URLRequest(url: url)
            if let res = URLCache.shared.cachedResponse(for: req) {
                let data = res.data
                if let img = UIImage(data: data) {
                    completion(img, url.absoluteString)
                } else {
                    let strUrl = url.absoluteString
                    guard let task = self.session?.downloadTask(with: url) else { return }
                    self.activeDownloads[strUrl] = (completion, progress, task) as (PhotoLoadingCompletion, DownloadProgress, Task)
                    task.resume()
                }
            } else {
                let strUrl = url.absoluteString
                guard let task = self.session?.downloadTask(with: url) else { return }
                self.activeDownloads[strUrl] = (completion, progress, task) as (PhotoLoadingCompletion, DownloadProgress, Task)
                task.resume()
            }
        }
    }
    
    func downloadGif(url: String, progress: @escaping DownloadProgress, completion: @escaping PhotoLoadingCompletion) {
        queue.sync { [weak self] in
            guard let self = self , let url = URL(string: url) else { return }
            let req = URLRequest(url: url)
            if let res = URLCache.shared.cachedResponse(for: req) {
                let data = res.data
                if let img = UIImage.gif(data: data) {
                    completion(img, url.absoluteString)
                } else {
                    let strUrl = url.absoluteString
                    guard let task = self.session?.downloadTask(with: url) else { return }
                    self.activeDownloads[strUrl] = (completion, progress, task) as (PhotoLoadingCompletion, DownloadProgress, Task)
                    task.resume()
                }
            } else {
                let strUrl = url.absoluteString
                guard let task = self.session?.downloadTask(with: url) else { return }
                self.activeDownloads[strUrl] = (completion, progress, task) as (PhotoLoadingCompletion, DownloadProgress, Task)
                task.resume()
            }
        }
    }
    
    func cancelDownload(image: Image) {
        queue.async { [weak self] in
            guard let self = self, let url = image.url else { return }
            if let task = self.activeDownloads[url]?.task {
                task.cancel()
                self.activeDownloads.removeValue(forKey: url)
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
            let data = try Data(contentsOf: location)
            guard let img = UIImage(data: data) else { return }
            
            queue.async { [weak self] in
                guard let self = self, let req = downloadTask.originalRequest,
                    let url = downloadTask.originalRequest?.url?.absoluteString else { return }
                if let comp = self.activeDownloads[url]?.completion,
                    let response = downloadTask.response {
                    if URLCache.shared.cachedResponse(for: req) == nil {
                        URLCache.shared.storeCachedResponse(CachedURLResponse(response: response, data: data), for: req)
                    }
                    DispatchQueue.main.async {
                        comp(img, url)
                    }
                    self.activeDownloads.removeValue(forKey: url)
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
            guard let self = self, let absoluteUrl = url?.absoluteString else { return }
            if let comp = self.activeDownloads[absoluteUrl]?.progress {
                DispatchQueue.main.async {
                    comp(progress)
                }
            }
        }
    }
}
