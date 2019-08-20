//
//  BigPhotoPickerFlowLayout.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/14/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

class BigPhotoPickerFlowLayout: UICollectionViewFlowLayout {
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
        let size = CGSize(width: 119 * 1.5, height: 357)
        guard let width = collectionView?.bounds.width else { return }
        itemSize = size
        sectionInset = UIEdgeInsets(top: self.minimumInteritemSpacing, left: 0.0, bottom: 0.0, right: 0.0)
        sectionInsetReference = .fromSafeArea
        minimumLineSpacing = 1
        minimumInteritemSpacing = 1
        footerReferenceSize = CGSize(width: (collectionView?.frame.width)!, height: 50.0)
    }
}
