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
    
    public typealias LoadingProgress = ((_ progress: Float) -> ())
    public typealias LoadingCompletion = ((_ image: UIImage) -> ())
    
    var vc: ImagesViewController?
    var progress: LoadingProgress?
    var completion: LoadingCompletion?
    var data: Image? = nil
    let placeholder = UIImage(named: "placeholder")
    var isLoaded = false
    
    override func awakeFromNib() {
        progressIndicatorView.progressColor = UIColor.black
        progressIndicatorView.backgroundColor = UIColor(white: 0, alpha: 0)
    }
    
    func configure(imageData: Image) {
        guard imageData.url != data?.url else {
            return
        }
        self.data = imageData
        imageView.image = placeholder
        
        progressIndicatorView.isHidden = false
        loadImage(url: imageData.url!, progress: { (progress) in
            DispatchQueue.main.async {
                self.updateProgressView(progress: progress)
            }
        }) { (img, url) in
            DispatchQueue.main.async {
                if url == self.data?.url {
                    self.isLoaded = true
                    self.imageView.image = img
                    self.progressIndicatorView.isHidden = true
                }
            }
        }
    }
    
    func loadImage(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ()) {
        isLoaded = false
        self.vc?.cellIsLoading(url: url, progress: progress, completion: completion)
    }
    
    func updateProgressView(progress: Float) {
        if progress == 1.0 { self.isLoaded = true }
        if self.isLoaded == false {
            self.isLoaded = false
            self.progressIndicatorView.setProgressWithAnimation(duration: 1, value: progress)
        }
    }
    
    override func prepareForReuse() {
        progressIndicatorView.isHidden = true
        imageView.image = placeholder
    }
}
