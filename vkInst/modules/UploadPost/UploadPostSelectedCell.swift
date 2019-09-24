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
        imageToUpload.layer.cornerRadius = 10
        cancelView.rotate()
        crossImageView.tintColor = ThemeService.currentTheme().primaryColor
    }
    
    func configureCell(asset: PHAsset) {
        let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        requestManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: nil) { image, _ in
            if self.identifier == asset.localIdentifier {
                self.imageToUpload.image = image
            }
        }
    }
    
    func updateProgress(progress: Float) {
        print("PROGRESS: \(progress)")
        cancelView.setProgressWithAnimation(value: progress)
    }
    
    func uploadComplete() {
        cancelView.isHidden = true
        cancelView.setDefaultProgress()
        cancelView.rotate()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageToUpload.image = nil
        cancelView.setDefaultProgress()
    }
}
