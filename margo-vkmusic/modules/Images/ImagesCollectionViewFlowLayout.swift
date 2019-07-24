//
//  ImagesCollectionViewFlowLayout.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/9/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol ImagesCollectionViewFlowLayoutProtocol: class {
    
}

class ImagesCollectionViewFlowLayout: UICollectionViewFlowLayout, ImagesCollectionViewFlowLayoutProtocol {
    var cellType: Int = 0
    
    weak var vc: ImagesViewController?
    override func prepare() {
        super.prepare()
        guard collectionView != nil else { return }
        if cellType == 0 {
            self.itemSize = CGSize(width: 135, height: 135)
            self.sectionInset = UIEdgeInsets(top: self.minimumInteritemSpacing, left: 0.0, bottom: 0.0, right: 0.0)
            self.sectionInsetReference = .fromSafeArea
            self.minimumLineSpacing = 3
            self.minimumInteritemSpacing = 1
        } else if cellType == 1 {
            self.itemSize = CGSize(width: 400, height: 650)
            self.sectionInset = UIEdgeInsets(top: self.minimumInteritemSpacing, left: 0.0, bottom: 0.0, right: 0.0)
            self.sectionInsetReference = .fromSafeArea
            self.minimumInteritemSpacing = 1
            self.minimumLineSpacing = 1
        }
    }
    
    func setGridView() {
        cellType = 0
        vc?.changeViewMode()
    }
    
    func setTapeView() {
        cellType = 1
        vc?.changeViewMode()
    }
}
