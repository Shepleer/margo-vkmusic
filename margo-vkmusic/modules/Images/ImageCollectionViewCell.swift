//
//  ImageCollectionViewCell.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/4/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var data: Image?

    func configure(vc: ImagesViewController) {
        vc.downloadImage(url: (data?.url!)!) { (img, res, err) in
            if res?.url?.absoluteString == self.data?.url {
                self.imageView.image = img
            }
        }
    }
}
