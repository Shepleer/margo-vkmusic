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
    var data: Image?
    let placeholder = UIImage(named: "placeholder")
    var isLoaded = false
    
    override func awakeFromNib() {
    }

    func configure(imageData: Image) {
        guard data?.url != imageData.url else {
            return
        }
        self.data = imageData
        imageView.image = placeholder
        progressIndicatorView.progressColor = UIColor.black
        progressIndicatorView.backgroundColor = UIColor(white: 0, alpha: 0)
        //if data?.img != nil {
        //    progressIndicatorView.isHidden = true
        //    imageView.image = data?.img
        
        progressIndicatorView.isHidden = false
        loadImage(url: self.data!.url!, progress: { (progress) in
            DispatchQueue.main.async {
                self.updateProgressView(progress: progress)
            }
        }) { (img) in
            DispatchQueue.main.async {
                self.isLoaded = true
                self.progressIndicatorView.isHidden = true
                self.imageView.image = img
            }
        }
    }
    
    func loadImage(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage) -> ()) {
        DispatchQueue.global().sync {
            isLoaded = false
            self.vc?.cellIsLoading(url: url, progress: progress, completion: completion)
        }
    }
    
    func updateProgressView(progress: Float) {
        DispatchQueue.main.async {
            if progress == 1.0 { self.isLoaded = true }
            if self.isLoaded == false {
                self.isLoaded = false
                self.progressIndicatorView.setProgressWithAnimation(duration: 1, value: progress)
            }
        }
    }
    
    override func prepareForReuse() {
        progressIndicatorView.isHidden = true
    }
}
