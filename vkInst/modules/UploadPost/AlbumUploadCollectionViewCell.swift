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
    
    var representedAssetIdentifier: String?
    var photoManager = PHCachingImageManager()
    var vc: UploadPostViewController?
    
    override func awakeFromNib() {
        photoView.layer.cornerRadius = 10
    }
    
    func configureCell(asset: PHAsset, cellSize: CGSize) {
        representedAssetIdentifier = asset.localIdentifier
        photoManager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: nil) { image, _ in
            self.photoView.image = image
        }
    }
    
    func getImage() -> UIImage? {
        guard let image = photoView.image else { return nil }
        return image
    }
    
    func updateUI() {
        if isSelected {
            contentView.backgroundColor = UIColor.black
            
        } else {
            contentView.backgroundColor = UIColor.clear
            
        }
    }
    
    override func prepareForReuse() {
        
    }
}
