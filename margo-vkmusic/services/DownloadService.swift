//
//  DownloadService.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/16/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

class DownloadService: NSObject {
    
    typealias Completion = ((_ download: UIImage, _ url: String) -> ())
    typealias Update = ((_ progress: Float) -> ())
    typealias Task = URLSessionDownloadTask
    typealias third = (completion: Completion, progress: Update, task: Task)
    typealias Downloads = [String: third]
    var activeDownloads: Downloads = [:]
    var session: URLSession? = nil
    
    let queue = DispatchQueue(label: "download_queue")
    func downloadImage(image: Image, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> () ) {
        queue.async { [weak self] in
            let url = URL(string: image.url!)!
            let req = URLRequest(url: url)
            if let res = URLCache.shared.cachedResponse(for: req) {
                let data = res.data
                let img = UIImage(data: data)
                completion(img!, url.absoluteString)
            } else {
                let strUrl = image.url!
                let task = self!.session?.downloadTask(with: url)
                self!.activeDownloads[strUrl] = (completion, progress, task) as! (DownloadService.Completion, DownloadService.Update, DownloadService.Task)
                task!.resume()
            }
        }
    }
    
    func cancelDownload(image: Image) {
        queue.async {
            let url = image.url
            if let task = self.activeDownloads[url!]?.task {
                task.cancel()
                self.activeDownloads[url!] = nil
            }
        }
    }
}

extension DownloadService: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            let img = UIImage(data: data)
            
            queue.async {
                let req = downloadTask.originalRequest
                let url = downloadTask.originalRequest?.url?.absoluteString
                if let comp = self.activeDownloads[url!]?.completion {
                    if URLCache.shared.cachedResponse(for: req!) == nil {
                        URLCache.shared.storeCachedResponse(CachedURLResponse(response: downloadTask.response!, data: data), for: req!)
                    }
                    DispatchQueue.main.async {
                        comp(img!, url!)
                    }
                    self.activeDownloads[url!] = nil
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        queue.async {
        let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        let url = downloadTask.originalRequest?.url
            if let comp = self.activeDownloads[(url?.absoluteString)!]?.progress {
                DispatchQueue.main.async {
                    comp(progress)
                }
            }
        }
    }
}
