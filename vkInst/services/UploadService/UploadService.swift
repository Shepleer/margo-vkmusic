//
//  UploadService.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/13/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import Foundation
import UIKit

typealias PostUploadCompletion = (_ id: Int) -> ()

protocol UploadServiceProtocol {
    func getWallUploadServer()
    func transferPhotosToServer()
    func saveChanges()
    func createPost(message: String?, completion: @escaping PostUploadCompletion)
    func pushImagesToUpload(_ images: [UIImage])
}

class UploadService {
    var requestService: APIService?
    var uploadServer: UploadServer? = nil
    var uploadPhotos = [UploadServerPhotoResponse?]()
    var photosIds = [Int]()
    var imagesToUpload = [UIImage]()
    
    private struct RequestConfigurations {
        static let userId = UserDefaults.standard.string(forKey: "userId")!
        static let token = UserDefaults.standard.string(forKey: "accessToken")!
    }
}

extension UploadService: UploadServiceProtocol {
    
    func pushImagesToUpload(_ images: [UIImage]) {
        imagesToUpload = images
        transferPhotosToServer()
    }

    func getWallUploadServer() {
        let url = "https://api.vk.com/method/photos.getWallUploadServer?access_token=\(RequestConfigurations.token)&v=5.101"
        requestService?.getData(urlStr: url, method: .get, completion: { (response: UploadServer?, err) in
            guard let response = response else { return }
            self.uploadServer = response
        })
    }
    
    func transferPhotosToServer() {
        guard let url = uploadServer?.uploadUrl else { return }
        let fileName = "just.jpeg"
        let boundary = "Boundary-\(UUID().uuidString)"
        for image in imagesToUpload {
            guard let imageData = image.jpegData(compressionQuality: 1) else { return }
            guard let data = converImageDataToFormData(originData: imageData, boundary: boundary, fileName: fileName) else { return }
            let contentLength = String(data.count)
            requestService?.getData(urlStr: url, method: .post, body: data, headers: ["Content-Type": "multipart/form-data; boundary=\(boundary)", "Content-Length": contentLength], completion: { (response: UploadServerPhotoResponse?, err) in
                guard let res = response else { return }
                self.uploadPhotos.append(res)
                if self.uploadPhotos.count == self.imagesToUpload.count {
                    self.saveChanges()
                }
            })
        }
    }
    
    func saveChanges() {
        for uploadPhoto in uploadPhotos {
            guard let server = uploadPhoto?.server else { return }
            guard let photo = uploadPhoto?.photo else { return }
            guard let hash = uploadPhoto?.hash else { return }
            let url = "https://api.vk.com/method/photos.saveWallPhoto?user_id=\(RequestConfigurations.userId)&photo=\(photo)&server=\(server)&hash=\(hash)&access_token=\(RequestConfigurations.token)&v=5.101"
            requestService?.getData(urlStr: url, method: .get, completion: { (response: [Image]?, err) in
                guard let id = response?.first?.id else { return }
                self.photosIds.append(id)
            })
        }
    }
    
    func createPost(message: String?, completion: @escaping PostUploadCompletion) {
        guard message != nil || (photosIds != nil && photosIds.isEmpty == false) else { return }
        let ownerId = RequestConfigurations.userId
        var attachments = ""
        var userMessage = ""
        if let message = message {
            userMessage = "message=\(message)"
            if photosIds != nil && photosIds.isEmpty == false {
                userMessage.append("&")
            }
        }
        if photosIds == photosIds {
            if !photosIds.isEmpty {
                attachments.append("attachments=")
                for i in 0...photosIds.count - 1 {
                    let attachment = "photo\(ownerId)_\(photosIds[i])"
                    if i != photosIds.count - 1 {
                        attachments.append(attachment + ",")
                    } else {
                        attachments.append(attachment)
                    }
                }
            }
        }
        let url = "https://api.vk.com/method/wall.post?\(userMessage)\(attachments)&access_token=\(RequestConfigurations.token)&v=5.101"
        requestService?.getData(urlStr: url, method: .get, completion: { (response: CreatePostResponse?, err) in
            if let id = response?.postId {
                completion(id)
            }
        })
    }
}

private extension UploadService {
    func converImageDataToFormData(originData: Data, boundary: String, fileName: String) -> Data? {
        let body = NSMutableData()
        let boundaryPrefix = "--\(boundary)\r\n"
        body.appendString(boundaryPrefix)
        body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"sss.jpg\"\r\n")
        body.appendString("Content-Type: image/jpg\r\n\r\n")
        body.append(originData)
        body.appendString("\r\n")
        body.appendString("--".appending(boundary.appending("--")))
        return body as Data
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        guard let data = string.data(using: .utf8, allowLossyConversion: false) else { return }
        append(data)
    }
}
