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
    @IBOutlet weak var DeckImageView: UIImageView!
    
    weak var vc: ImagesViewController?
    var progress: DownloadProgress?
    var completion: LoadingCompletion?
    var data: Post? = nil
    
    override func awakeFromNib() {
    }
    
    func configure(postData: Post) {
        guard postData.photos?.first?.url != data?.photos?.first?.url || postData.gifs?.first?.url != data?.gifs?.first?.url else { return }
        if let photosCount = postData.photos?.count,
            let gifsCount = postData.gifs?.count {
            if (photosCount + gifsCount) > 1 {
                DeckImageView.isHidden = false
            } else {
                DeckImageView.isHidden = true
            }
        }
        data = postData
        imageView.alpha = 0
        DeckImageView.tintColor = UIColor.white

        if let url = postData.gifs?.first?.url {
            loadGif(url: url, progress: { (progress) in
            }) { (gif, url) in
                if url == self.data?.gifs?.first?.url {
                    self.imageView.image = gif
                    UIView.animate(withDuration: 0.1, animations: {
                        self.imageView.alpha = 1
                    })
                    self.imageView.startAnimating()
                }
            }
        } else if let url = postData.photos?.first?.url {
            loadImage(url: url, progress: { (progress) in
            }) { (img, url) in
                if url == self.data?.photos?.first?.url {
                    self.imageView.image = img
                    UIView.animate(withDuration: 0.1, animations: {
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
