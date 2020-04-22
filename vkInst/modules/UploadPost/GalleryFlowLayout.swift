//
//  SmallPhotoPickerFlowLayout.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/14/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

class GalleryFlowLayout: UICollectionViewFlowLayout {
    private struct Constants {
        static let itemSize = CGSize(width: 120, height: 120)
        static let itemRightEdgeInset = CGFloat(10)
    }
    
    
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
        itemSize = Constants.itemSize
        sectionInsetReference = .fromSafeArea
        minimumInteritemSpacing = 0
        sectionInset = UIEdgeInsets(top: 0.0, left: 10, bottom: 0.0, right: Constants.itemRightEdgeInset)
    }
}
