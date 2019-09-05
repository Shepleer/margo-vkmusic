//
//  UploadPostSelectedCell.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/19/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit
import Photos


class UploadPostSelectedCell: UICollectionViewCell {
    
    @IBOutlet weak var crossImageView: UIImageView!
    @IBOutlet weak var cancelView: ProgressIndicatorView!
    @IBOutlet weak var imageToUpload: UIImageView!
    
    var requestManager = PHImageManager()
    weak var vc: UploadPostViewControllerProtocol?
    var asset: PHAsset?
    var fileName: String? = nil
    var photoId: Int?
    var id: Int? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageToUpload.layer.cornerRadius = imageToUpload.bounds.width / 4
        cancelView.rotate()
    }
    
    func configureCell() {
        //guard id == nil else { return }
        guard let asset = asset else { fatalError() }
        requestManager.requestImage(for: asset, targetSize: CGSize(width: 120, height: 120), contentMode: .aspectFill, options: nil) { (image, nil) in
            self.imageToUpload.image = image
        }
        
        //let deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        //let requestOptions = PHImageRequestOptions()
        //requestOptions.deliveryMode = deliveryMode
//        requestManager.requestImageData(for: asset, options: requestOptions) { (data, str, orientation, nil) in
//            guard let data = data else { return }
//            let fileName = UUID().uuidString
//            self.fileName = fileName
//            self.vc?.startUploadPhoto(data: data, fileName: fileName, progress: { (progress) in
//                self.cancelView.setProgressWithAnimation(value: progress)
//            }, completion: { (id) in
//                self.id = id
//                self.vc?.photoDidUpload(id: id)
//            })
//        }
    }
    
    func updateProgress(progress: Float) {
        cancelView.setProgressWithAnimation(value: progress)
    }
    
    func uploadComplete() {
        cancelView.isHidden = true
    }
    
    //func removeItem(completion: @escaping CancelCompletion) {
    //    guard let fileName = fileName else { return }
    //    vc?.cancelUpload(id: id, fileName: fileName)
    //}
}
