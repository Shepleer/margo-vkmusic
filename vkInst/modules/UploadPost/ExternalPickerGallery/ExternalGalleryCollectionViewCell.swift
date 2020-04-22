//
//  ExternalGalleryCollectionViewCell.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/16/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit
import Photos

class ExternalGalleryCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var circularView: UIView!
    @IBOutlet weak var serialNumberLabel: UILabel!
    
    var representedAssetIdentifier: String!
    var requestManager = PHImageManager()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        circularView.layer.cornerRadius = circularView.bounds.width / 2
        circularView.layer.borderColor = UIColor.white.cgColor
        circularView.layer.borderWidth = 2
        serialNumberLabel.isHidden = true
    }
    
    func setSerialNumber(number: Int) {
        isSelected = true
        serialNumberLabel.text = "\(number)"
        serialNumberLabel.isHidden = false
    }
    
    func deselectSerialNumber() {
        serialNumberLabel.text = nil
        serialNumberLabel.isHidden = true
    }
    
    func configureCell(with asset: PHAsset, itemSize: CGSize) {
        requestManager.requestImage(for: asset, targetSize: itemSize, contentMode: .aspectFill, options: nil) { (image, nil) in
            if self.representedAssetIdentifier == asset.localIdentifier {
                self.imageView.image = image
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        serialNumberLabel.text = nil
        serialNumberLabel.isHidden = true
    }
}
