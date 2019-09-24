//
//  ImageCollectionViewCell.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/4/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

class GridCollectionViewCell: UICollectionViewCell {
    private struct Constants {
        static let photoAppearAnimationDuration = 0.1
    }
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var deckImageView: UIImageView!
    @IBOutlet weak var gifIndicatorImageView: UIImageView!
    
    weak var vc: GalleryViewControllerCellDelegate?
    var progress: DownloadProgress?
    var completion: LoadingCompletion?
    var data: Post? = nil
    
    override func layoutSubviews() {
        imageView.alpha = 0
        deckImageView.tintColor = UIColor.white
    }
    
    func configure(postData: Post) {
        guard postData.photos?.first?.url != data?.photos?.first?.url || postData.gifs?.first?.url != data?.gifs?.first?.url else { return }
        if let photosCount = postData.photos?.count,
            let gifsCount = postData.gifs?.count {
            if (photosCount + gifsCount) > 1 {
                deckImageView.isHidden = false
            } else {
                deckImageView.isHidden = true
            }
            if gifsCount != 0 {
                gifIndicatorImageView.isHidden = false
            } else {
                gifIndicatorImageView.isHidden = true
            }
        }
        data = postData

        if let url = postData.gifs?.first?.url {
            loadGif(url: url, progress: { (progress) in
            }) { [weak self] (gif, url) in
                if let self = self,
                    url == self.data?.gifs?.first?.url {
                    self.imageView.image = gif.images?.first
                    self.imageView.animationRepeatCount = 0
                    self.imageView.startAnimating()
                    UIView.animate(withDuration: Constants.photoAppearAnimationDuration, animations: {
                        self.imageView.alpha = 1
                    })
                }
            }
        } else if let url = postData.photos?.first?.url {
            loadImage(url: url, progress: { (progress) in
            }) { [weak self] (img, url) in
                if let self = self,
                    url == self.data?.photos?.first?.url {
                    self.imageView.image = img
                    UIView.animate(withDuration: Constants.photoAppearAnimationDuration, animations: {
                        self.imageView.alpha = 1
                    })
                }
            }
        }
    }
    
    func loadGif(url: String, progress: @escaping DownloadProgress, completion: @escaping PhotoLoadingCompletion) {
        vc?.loadGif(url: url, progress: progress, completion: completion)
    }
    
    func loadImage(url: String, progress: @escaping DownloadProgress, completion: @escaping PhotoLoadingCompletion) {
        vc?.cellIsLoading(url: url, progress: progress, completion: completion)
    }
}
