//
//  OpenMoreCollectionViewCell.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/19/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

class OpenMoreCollectionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        contentView.layer.cornerRadius = contentView.bounds.width / 4
        contentView.layer.borderWidth = 3
        contentView.layer.borderColor = UIColor.white.cgColor
    }
    
}
