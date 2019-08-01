//
//  ImagesCollectionViewFlowLayout.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/9/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

enum CellType {
    case Grid
    case Tape
}

class ImagesCollectionViewFlowLayout: UICollectionViewFlowLayout {
    var cellType: CellType = .Grid
    weak var vc: ImagesViewController?
}

extension ImagesCollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        guard collectionView != nil else { return }
        if cellType == .Grid {
            let size = ((collectionView?.frame.width)! / 3) - 1
            self.itemSize = CGSize(width: size, height: size)
            self.sectionInset = UIEdgeInsets(top: self.minimumInteritemSpacing, left: 0.0, bottom: 0.0, right: 0.0)
            self.sectionInsetReference = .fromSafeArea
            self.minimumLineSpacing = 1
            self.minimumInteritemSpacing = 1
        } else if cellType == .Tape {
            self.itemSize = CGSize(width: (collectionView?.frame.width)!, height: 500)
            self.sectionInset = UIEdgeInsets(top: self.minimumInteritemSpacing, left: 0.0, bottom: 0.0, right: 0.0)
            self.sectionInsetReference = .fromSafeArea
            self.minimumInteritemSpacing = 1
            self.minimumLineSpacing = 1
        }
    }
}