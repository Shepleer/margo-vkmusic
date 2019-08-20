//
//  DownloadService.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/16/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

typealias LoadingProgress = ((_ progress: Float) -> ())
typealias LoadingCompletion = ((_ image: UIImage) -> ())
typealias PhotoLoadingCompletion = ((_ download: UIImage, _ url: String) -> ())
typealias Update = ((_ progress: Float) -> ())
typealias Task = URLSessionDownloadTask
typealias TaskCompletion = (completion: PhotoLoadingCompletion, progress: Update, task: Task)
typealias Downloads = [String: TaskCompletion]

class DownloadService: NSObject {
    private var activeDownloads: Downloads = [:]
    var session: URLSession? = nil
    
    let queue = DispatchQueue(label: "download_queue")
    func downloadImage(url: String, progress: @escaping LoadingProgress, completion: @escaping PhotoLoadingCompletion) {
        queue.sync { [weak self] in
            guard let url = URL(string: url) else { return }
            let req = URLRequest(url: url)
            if let res = URLCache.shared.cachedResponse(for: req) {
                let data = res.data
                if let img = UIImage(data: data) {
                    completion(img, url.absoluteString)
                } else {
                    let strUrl = url.absoluteString
                    let task = self!.session?.downloadTask(with: url)
                    self!.activeDownloads[strUrl] = (completion, progress, task) as! (PhotoLoadingCompletion, Update, Task)
                    task!.resume()
                }
            } else {
                let strUrl = url.absoluteString
                let task = self!.session?.downloadTask(with: url)
                self!.activeDownloads[strUrl] = (completion, progress, task) as! (PhotoLoadingCompletion, Update, Task)
                task!.resume()
            }
        }
    }
    
    func downloadGif(url: String, progress: @escaping LoadingProgress, completion: @escaping PhotoLoadingCompletion) {
        queue.sync { [weak self] in
            guard let url = URL(string: url) else { return }
            let req = URLRequest(url: url)
            if let res = URLCache.shared.cachedResponse(for: req) {
                let data = res.data
                if let img = UIImage.gif(data: data) {
                    completion(img, url.absoluteString)
                } else {
                    let strUrl = url.absoluteString
                    let task = self!.session?.downloadTask(with: url)
                    self!.activeDownloads[strUrl] = (completion, progress, task) as! (PhotoLoadingCompletion, Update, Task)
                    task!.resume()
                }
            } else {
                let strUrl = url.absoluteString
                let task = self!.session?.downloadTask(with: url)
                self!.activeDownloads[strUrl] = (completion, progress, task) as! (PhotoLoadingCompletion, Update, Task)
                task!.resume()
            }
        }
    }
    
    func cancelDownload(image: Image) {
        queue.async { [weak self] in
            guard let url = image.url else { return }
            if let task = self!.activeDownloads[url]?.task {
                task.cancel()
                self!.activeDownloads[url] = nil
            }
        }
    }
}

extension DownloadService: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            guard let img = UIImage(data: data) else { return }
            
            queue.async { [weak self] in
                guard let req = downloadTask.originalRequest else { return }
                guard let url = downloadTask.originalRequest?.url?.absoluteString else { return }
                if let comp = self!.activeDownloads[url]?.completion {
                    if URLCache.shared.cachedResponse(for: req) == nil {
                        URLCache.shared.storeCachedResponse(CachedURLResponse(response: downloadTask.response!, data: data), for: req)
                    }
                    DispatchQueue.main.async {
                        comp(img, url)
                    }
                    self!.activeDownloads[url] = nil
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
            guard let absoluteUrl = url?.absoluteString else { return }
            if let comp = self!.activeDownloads[absoluteUrl]?.progress {
                DispatchQueue.main.async {
                    comp(progress)
                }
            }
        }
    }
}
