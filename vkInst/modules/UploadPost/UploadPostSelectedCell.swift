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
    var vc: UploadPostViewControllerProtocol?
    var asset: PHAsset?
    var fileName: String? = nil
    var photoId: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageToUpload.layer.cornerRadius = imageToUpload.bounds.width / 4
        //cancelView.layer.cornerRadius = cancelView.bounds.width / 4
        //cancelView.layer.borderWidth = 3
        //cancelView.layer.borderColor = UIColor.white.cgColor
        cancelView.rotate()
    }
    
    func configureCell() {
        guard let asset = asset else { fatalError() }
        requestManager.requestImage(for: asset, targetSize: CGSize(width: 120, height: 120), contentMode: .aspectFill, options: nil) { (image, nil) in
            self.imageToUpload.image = image
        }
        let deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = deliveryMode
        requestManager.requestImageData(for: asset, options: requestOptions) { (data, str, orientation, nil) in
            guard let data = data else { return }
            let fileName = UUID().uuidString
            self.fileName = fileName
            self.vc?.startUploadPhoto(data: data, fileName: fileName, progress: { (progress) in
                self.cancelView.setProgressWithAnimation(duration: 1.5, value: progress)
            }, completion: { (id) in
                self.vc?.photoDidUpload(id: id)
                self.cancelView.layer.removeAnimation(forKey: "animateprogress")
                self.cancelView.setProgressWithAnimation(duration: 1.0, value: 1.0)
            })
        }
    }
}
