//
//  OpenMoreCollectionViewCell.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/19/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

class OpenMoreCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var plusImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        plusImage.tintColor = ThemeService.currentTheme().primaryColor
    }
}
