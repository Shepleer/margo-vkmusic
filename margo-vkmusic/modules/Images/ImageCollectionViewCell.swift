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

    func configure() {
        if let res = URLCache.shared.cachedResponse(for: URLRequest(url: URL(string: data!.url!)!)) {
            DispatchQueue.main.async {
                self.isLoaded = true
                self.imageView.image = UIImage(data: res.data)
            }
        } else {
            progressIndicatorView.isHidden = false
            loadImage(url: data!.url!, progress: { (progress) in
                DispatchQueue.main.async {
                    self.updateProgressView(progress: progress)
                }
            }) { (img) in
                DispatchQueue.main.async {
                    self.isLoaded = true
                    self.progressIndicatorView.isHidden = true
                    self.imageView.image = img
                    self.data?.img = img
                }
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
        progressIndicatorView.setProgressWithAnimation(duration: 0.7, value: progress)
    }
    
    override func prepareForReuse() {
        if isLoaded == false {
            vc?.cancellingDownload(image: data!)
        } else {
            imageView.image = placeholder
        }
        progressIndicatorView.isHidden = true
    }
}
