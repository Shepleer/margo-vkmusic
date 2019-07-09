//
//  ImagesCollectionViewFlowLayout.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/9/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

class ImagesCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
        guard collectionView != nil else { return }
        self.itemSize = CGSize(width: 135, height: 135)
        self.sectionInset = UIEdgeInsets(top: self.minimumInteritemSpacing, left: 0.0, bottom: 0.0, right: 0.0)
        self.sectionInsetReference = .fromSafeArea
        self.minimumLineSpacing = 3
        self.minimumInteritemSpacing = 1
    }
}
