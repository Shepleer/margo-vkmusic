//
//  TestDownloadService.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 10/3/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import UIKit

struct MediaFile {
    var url: URL?
    var image: UIImage?
    var type: MediaType?
    var completion: MediaLoadingCompletion?
    var progressCompletion: DownloadProgress?
    var task: URLSessionDownloadTask?
    
    init(url: String) {
        guard let absoluteUrl = URL(string: url) else { return }
        self.url = absoluteUrl
    }
}

protocol TestDownloadServiceProtocol: class {
    func cancelDownload(image: Image)
    func invalidateSession()
    //func downloadMedia(url: String, type: MediaType, progress: @escaping DownloadProgress, completion: @escaping MediaLoadingCompletion)
    
    func downloadMedia(with mediaFile: MediaFile, progress: @escaping DownloadProgress, completion: @escaping MediaLoadingCompletion)
}

class TestDownloadService: NSObject {
    var downloadingMediaFiles = [String: MediaFile]()
    var session: URLSession? = nil
    let queue = DispatchQueue.global(qos: .default)
}

extension TestDownloadService: TestDownloadServiceProtocol {
    func cancelDownload(image: Image) {
//        queue.async { [weak self] in
//            guard let self = self,
//                let url = image.url else { return }
//            if let task = self.activeDownloads[url]?.task {
//                task.cancel()
//                DispatchQueue.main.async { [weak self] in
//                    guard let self = self else { return }
//                    self.activeDownloads.removeValue(forKey: url)
//                }
//            }
//        }
    }
    
    func invalidateSession() {
        downloadingMediaFiles.removeAll()
        session?.invalidateAndCancel()
    }
    
    func downloadMedia(with mediaFile: MediaFile, progress: @escaping DownloadProgress, completion: @escaping MediaLoadingCompletion) {
        queue.async { [unowned self] in
            guard //let self = self,
                let session = self.session,
                let url = mediaFile.url,
                let type = mediaFile.type
                else { return }
            let request = URLRequest(url: url)
            if let image = self.getCachedResponse(for: request, type: type) {
                completion(image, url.absoluteString)
            }
            let urlString = url.absoluteString
            let task = session.downloadTask(with: request)
            var downloadingFile = MediaFile(url: urlString)
            
            downloadingFile.completion = completion
            downloadingFile.progressCompletion = progress
            downloadingFile.task = task
            downloadingFile.type = type
            DispatchQueue.main.async {
            self.downloadingMediaFiles[urlString] = downloadingFile
            }
            task.resume()
        }
    }
}

extension TestDownloadService: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            guard let absoluteUrl = downloadTask.originalRequest?.url?.absoluteString,
                let type = downloadingMediaFiles[absoluteUrl]?.type,
                let originalRequest = downloadTask.originalRequest else { return }
            let data = try Data(contentsOf: location)
            guard let image = createMediaFile(with: type, data: data) else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self,
                    let completion = self.downloadingMediaFiles[absoluteUrl]?.completion,
                    let response = downloadTask.response else { return }
                self.cacheMediaFile(with: originalRequest, response: response, data: data)
                completion(image, absoluteUrl)
                self.downloadingMediaFiles.removeValue(forKey: absoluteUrl)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

private extension TestDownloadService {
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
    
    func cacheMediaFile(with request: URLRequest, response: URLResponse, data: Data) {
        if URLCache.shared.cachedResponse(for: request) == nil {
            let cachedUrlResponse = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedUrlResponse, for: request)
        }
    }
}
