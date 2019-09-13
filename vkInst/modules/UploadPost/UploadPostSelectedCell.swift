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
    
    private struct Constants {
        static let targetSize = CGSize(width: 120, height: 120)
        static let itemCornerRadius = CGFloat(10)
    }
    
    @IBOutlet weak var crossImageView: UIImageView!
    @IBOutlet weak var cancelView: ProgressIndicatorView!
    @IBOutlet weak var imageToUpload: UIImageView!
    
    var requestManager = PHImageManager()
    weak var vc: UploadPostViewControllerProtocol?
    var asset: PHAsset?
    var fileName: String? = nil
    var photoId: Int?
    var id: Int? = nil
    var identifier: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageToUpload.layer.cornerRadius = Constants.itemCornerRadius
        cancelView.rotate()
        crossImageView.tintColor = ThemeService.currentTheme().primaryColor
    }
    
    func configureCell() {
        guard let asset = asset else { fatalError() }
        requestManager.requestImage(for: asset, targetSize: Constants.targetSize, contentMode: .aspectFill, options: nil) { (image, nil) in
            if self.identifier == asset.localIdentifier {
                self.imageToUpload.image = image
            }
        }
    }
    
    func updateProgress(progress: Float) {
        cancelView.setProgressWithAnimation(value: progress)
    }
    
    func uploadComplete() {
        cancelView.isHidden = true
    }
}
