//
//  UploadService.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/13/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import ObjectMapper


typealias PostUploadCompletion = (_ id: Int?, _ error: RequestError?, _ url: String) -> ()
typealias UploadProgress = ((_ progress: Float) -> ())
typealias UploadTaskComletions = (completion: PostUploadCompletion, progress: UploadProgress, cancel: CancelCompletion, task: URLSessionUploadTask)
typealias ActiveUploads = [String: UploadTaskComletions]
typealias CancelCompletion = (_ isCanceled: Bool) -> ()

protocol UploadServiceProtocol {
    func transferPhotosToServer(imageData: Data, fileName: String, progress: @escaping UploadProgress, completion: @escaping PostUploadCompletion, cancel: @escaping CancelCompletion)
    func getWallUploadServer()
    func cancelUpload(fileName: String)
    func invalidateSession()
}

class UploadService: NSObject {
    
    private struct RequestConfigurations {
        static let fileNameHeader = "fileName"
        static let contentTypeHeader = "Content-Type"
        static let contentLenghtHeader = "Content-Length"
        static let getUploadServerUrlTemplate = "https://api.vk.com/method/photos.getWallUploadServer?access_token=[token]&v=5.101"
        static let saveChangesUrlTemplate = "https://api.vk.com/method/photos.saveWallPhoto?user_id=[userId]&photo=[photo]&server=[server]&hash=[hash]&access_token=[token]&v=5.101"
    }
    
    private var requestService: APIService
    var uploadServer: UploadServer?
    weak var session: URLSession?
    var photosIds = [Int]()
    var activeUploads: ActiveUploads = [:]
    
    init(requestService: APIService) {
        self.requestService = requestService
    }
    
    private var userId = UserDefaults.standard.string(forKey: "userId") ?? "Token has expired"
    private var token = UserDefaults.standard.string(forKey: "accessToken") ?? "Token has expired"
}

extension UploadService: UploadServiceProtocol {
    
    func invalidateSession() {
        session?.invalidateAndCancel()
    }
    
    func transferPhotosToServer(imageData: Data, fileName: String, progress: @escaping UploadProgress, completion: @escaping PostUploadCompletion, cancel: @escaping CancelCompletion) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self,
                let session = self.session,
                let req = self.buildUploadRequest(imageData: imageData, fileName: fileName)
                else { return }
            let uploadTask = session.uploadTask(withStreamedRequest: req)
            self.activeUploads[fileName] = (completion, progress, cancel, uploadTask) as (PostUploadCompletion, UploadProgress, CancelCompletion, URLSessionUploadTask)
            uploadTask.resume()
        }
    }
    
    func getWallUploadServer() {
        let url = RequestConfigurations.getUploadServerUrlTemplate
                    .replacingOccurrences(of: "[token]", with: token)
        requestService.getData(urlStr: url, method: .get, completion: { [weak self] (response: UploadServer?, err) in
            guard let self = self,
                let response = response else { return }
            self.uploadServer = response
        })
    }
    
    func cancelUpload(fileName: String) {
        guard let task = activeUploads[fileName]?.task,
            let cancel = activeUploads[fileName]?.cancel else { return }
        task.cancel()
        cancel(true)
        activeUploads.removeValue(forKey: fileName)
    }
}

private extension UploadService {
    func buildUploadRequest(imageData: Data, fileName: String) -> URLRequest? {
        guard let urlString = uploadServer?.uploadUrl else { return nil }
        let boundary = "Boundary-\(UUID().uuidString)"
        guard let data = converImageDataToFormData(originData: imageData, boundary: boundary, fileName: fileName) else { return nil }
        let contentLenght = String(data.count)
        guard let url = URL(string: urlString) else { return nil }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("\(fileName)", forHTTPHeaderField: RequestConfigurations.fileNameHeader)
        req.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: RequestConfigurations.contentTypeHeader)
        req.addValue(contentLenght, forHTTPHeaderField: RequestConfigurations.contentLenghtHeader)
        req.httpBody = data
        return req
    }
    
    func converImageDataToFormData(originData: Data, boundary: String, fileName: String) -> Data? {
        let body = NSMutableData()
        let boundaryPrefix = "--\(boundary)\r\n"
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName).jpg\"\r\n")
        body.appendString("Content-Type: image/jpg\r\n\r\n")
        body.append(originData)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        return body as Data
    }
    
    func saveChanges(uploadPhoto: UploadServerPhotoResponse, fileName: String) {
        guard let server = uploadPhoto.server,
            let photo = uploadPhoto.photo,
            let hash = uploadPhoto.hash
            else { return }
        let url = RequestConfigurations.saveChangesUrlTemplate
                    .replacingOccurrences(of: "[userId]", with: "\(userId)")
                    .replacingOccurrences(of: "[photo]", with: "\(photo)")
                    .replacingOccurrences(of: "[server]", with: "\(server)")
                    .replacingOccurrences(of: "[hash]", with: "\(hash)")
                    .replacingOccurrences(of: "[token]", with: token)
        requestService.getData(urlStr: url, method: .get, completion: { [weak self] (response: [Image]?, err) in
            DispatchQueue.main.async { [weak self] in
                guard let self = self,
                    let completion = self.activeUploads[fileName]?.completion
                    else { return }
                if let id = response?.first?.id {
                    completion(id, nil, url)
                } else if let err = err as? RequestError {
                    completion(nil, err, url)
                }
            }
        })
    }
}

extension UploadService: URLSessionTaskDelegate, URLSessionDataDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self,
                let fileName = task.originalRequest?.value(forHTTPHeaderField: RequestConfigurations.fileNameHeader)
                else { return }
            let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
            guard let progressCompletion = self.activeUploads[fileName]?.progress else { return }
            DispatchQueue.main.async {
                progressCompletion(progress)
            }
        }
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else { return }
            guard let model = Mapper<UploadServerPhotoResponse>().map(JSON: json) else { return }
            guard let fileName = dataTask.originalRequest?.value(forHTTPHeaderField: RequestConfigurations.fileNameHeader) else { return }
            saveChanges(uploadPhoto: model, fileName: fileName)
        } catch {
            fatalError()
        }
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        guard let data = string.data(using: .utf8, allowLossyConversion: false) else { return }
        append(data)
    }
}
