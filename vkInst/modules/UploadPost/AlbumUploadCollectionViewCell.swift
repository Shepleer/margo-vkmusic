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
    
    private struct Constants {
        static let notSelectedSerialNumberLabelText = ""
        static let photoViewCornerRadius = CGFloat(10)
        static let photoViewBorderWidth = CGFloat(2)
    }
    
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var circularView: UIView!
    @IBOutlet weak var serialNumberLabel: UILabel!
    
    var representedAssetIdentifier: String?
    var photoManager = PHImageManager()
    weak var vc: UploadPostViewController?
    var identifier: String?
    
    override func awakeFromNib() {
        serialNumberLabel.text = Constants.notSelectedSerialNumberLabelText
        photoView.layer.cornerRadius = Constants.photoViewCornerRadius
        circularView.layer.cornerRadius = circularView.bounds.width / 2
        circularView.layer.borderColor = UIColor.white.cgColor
        circularView.layer.borderWidth = Constants.photoViewBorderWidth
        serialNumberLabel.isHidden = true
        serialNumberLabel.text = nil
    }
    
    func configureCell(asset: PHAsset, cellSize: CGSize) {
        representedAssetIdentifier = asset.localIdentifier
        let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        photoManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: nil) { image, _ in
            if self.identifier == asset.localIdentifier {
                self.photoView.image = image
            }
        }
    }
    
    func setSerialNumber(number: Int) {
        serialNumberLabel.text = "\(number)"
        serialNumberLabel.isHidden = false
    }
    
    func removeSerialNumber() {
        serialNumberLabel.text = Constants.notSelectedSerialNumberLabelText
        serialNumberLabel.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        serialNumberLabel.isHidden = true
        serialNumberLabel.text = nil
    }
}
