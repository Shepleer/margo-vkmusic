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
        let size = ((collectionView?.frame.width)! / 3) - 1
        itemSize = CGSize(width: size, height: size)
        sectionInset = UIEdgeInsets(top: self.minimumInteritemSpacing, left: 0.0, bottom: 0.0, right: 0.0)
        sectionInsetReference = .fromSafeArea
        minimumLineSpacing = 1
        minimumInteritemSpacing = 1
        footerReferenceSize = CGSize(width: (collectionView?.frame.width)!, height: 50.0)
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        vc?.setCurrentContentOffset(offset: proposedContentOffset)
        return proposedContentOffset
    }
}

class TapeCollectionViewFlowLayout: UICollectionViewFlowLayout {
    weak var vc: ImagesViewController?
    var isHeightCalculated = false
    override func prepare() {
        guard collectionView != nil else { return }
        //estimatedItemSize = CGSize(width: (collectionView?.frame.width)!, height: 200)
        //itemSize = UICollectionViewFlowLayout.automaticSize
        itemSize = CGSize(width: (collectionView?.frame.width)!, height: 524)
        sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        sectionInsetReference = .fromSafeArea
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        vc?.setCurrentContentOffset(offset: proposedContentOffset)
        return proposedContentOffset
    }
}
