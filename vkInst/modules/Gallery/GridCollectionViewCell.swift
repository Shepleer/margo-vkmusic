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
    
    func configure(postData: Post) {
        guard postData.photos?.first?.url != data?.photos?.first?.url || postData.gifs?.first?.url != data?.gifs?.first?.url else { return }
        configureUI()
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
        
        guard let url = postData.gifs?.first?.previewUrl ?? postData.photos?.first?.url else { return }
        
        vc?.cellIsLoading(url: url, progress: { (progress) in
            
        }, completion: { [weak self] (image, localUrl) in
            guard let self = self else { return }
            if url == localUrl {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.imageView.image = image
                    UIView.animate(withDuration: Constants.photoAppearAnimationDuration) {
                        self.imageView.alpha = 1
                    }
                }
            }
        })
    }
        
    func loadImage(url: String, progress: @escaping DownloadProgress, completion: @escaping MediaLoadingCompletion) {
        vc?.cellIsLoading(url: url, progress: progress, completion: completion)
    }
    
    private func configureUI() {
        imageView.alpha = 0
        deckImageView.tintColor = UIColor.white
    }
}
