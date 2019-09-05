//
//  AlbumUploadCollectionViewCell.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/14/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit
import Photos

class AlbumUploadCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var circularView: UIView!
    @IBOutlet weak var serialNumberLabel: UILabel!
    
    var representedAssetIdentifier: String?
    var photoManager = PHImageManager()
    weak var vc: UploadPostViewController?
    
    override func awakeFromNib() {
        serialNumberLabel.text = ""
        photoView.layer.cornerRadius = 10
        circularView.layer.cornerRadius = circularView.bounds.width / 2
        circularView.layer.borderColor = UIColor.white.cgColor
        circularView.layer.borderWidth = 2
        serialNumberLabel.isHidden = true
        serialNumberLabel.text = nil
    }
    
    func configureCell(asset: PHAsset, cellSize: CGSize) {
        representedAssetIdentifier = asset.localIdentifier
        photoManager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: nil) { image, _ in
            self.photoView.image = image
        }
    }
    
    func setSerialNumber(number: Int) {
        serialNumberLabel.text = "\(number)"
        serialNumberLabel.isHidden = false
    }
    
    func removeSerialNumber() {
        serialNumberLabel.text = ""
        serialNumberLabel.isHidden = true
    }
    
    override func prepareForReuse() {
        serialNumberLabel.isHidden = true
        serialNumberLabel.text = nil
    }
}
