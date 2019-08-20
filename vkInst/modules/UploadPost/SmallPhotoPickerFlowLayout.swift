//
//  SmallPhotoPickerFlowLayout.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/14/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

class SmallPhotoPickerFlowLayout: UICollectionViewFlowLayout {
    
    override init() {
        super.init()
        scrollDirection = .horizontal
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        scrollDirection = .horizontal
    }
    
    override func prepare() {
        super.prepare()
        guard collectionView != nil else { return }
        let size = 120
        itemSize = CGSize(width: size, height: size)
        sectionInsetReference = .fromSafeArea
        minimumLineSpacing = 10
        minimumInteritemSpacing = 0
        sectionInset = UIEdgeInsets(top: 0.0, left: 10, bottom: 0.0, right: 10)
    }
}
