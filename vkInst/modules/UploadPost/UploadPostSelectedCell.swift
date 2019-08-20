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
    
    @IBOutlet weak var cancelView: UIView!
    @IBOutlet weak var imageToUpload: UIImageView!
    
    var vc: UploadPostViewControllerProtocol?
    var asset: PHAsset?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func updatePresentation() {
        if isSelected {
            
        }
    }
    
    func configureCell(asset: PHAsset) {
        self.asset = asset
    }
    
    
}
