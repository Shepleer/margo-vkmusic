//
//  ImageCollectionViewCell.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/4/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var progressIndicatorView: ProgressIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    
    var vc: ImagesViewController?
    var progress: LoadingProgress?
    var completion: LoadingCompletion?
    var data: Image? = nil
    let placeholder = UIImage(named: "placeholder")
    var isLoaded = false
    
    override func awakeFromNib() {
        progressIndicatorView.progressColor = UIColor.black
    }
    
    func configure(imageData: Image) {
        guard imageData.url != data?.url else {
            return
        }
        data = imageData
        imageView.image = placeholder
        
        progressIndicatorView.isHidden = false
        loadImage(url: imageData.url!, progress: { (progress) in
            self.updateProgressView(progress: progress)
        }) { (img, url) in
            if url == self.data?.url {
                self.isLoaded = true
                self.imageView.image = img
                self.progressIndicatorView.isHidden = true
            }
        }
    }
    
    func loadImage(url: String, progress: @escaping LoadingProgress, completion: @escaping PhotoLoadingCompletion) {
        isLoaded = false
        vc?.cellIsLoading(url: url, progress: progress, completion: completion)
    }
    
    func updateProgressView(progress: Float) {
        if progress == 1.0 { self.isLoaded = true }
        if isLoaded == false {
            isLoaded = false
            progressIndicatorView.setProgressWithAnimation(duration: 1, value: progress)
        }
    }
    
    override func prepareForReuse() {
        progressIndicatorView.isHidden = true
        imageView.image = placeholder
    }
}
