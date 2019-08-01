//
//  CollectionViewCell.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/30/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

class TapeCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesCountLabel: UILabel!
    
    var vc: ImagesViewController?
    var progress: LoadingProgress?
    var completion: LoadingCompletion?
    var data: Image? = nil
    let placeholder = UIImage(named: "placeholder")
    var isLoaded = false
    
    override func awakeFromNib() {
        
    }
    
    func configure(imageData: Image) {
        guard imageData.url != data?.url else {
            return
        }
        self.data = imageData
        imageView.image = placeholder
        
        updateLikesList(photo: imageData, setLikesCount: { (likes) in
            self.likesCountLabel.text = "\(likes) likes"
        }) { (isLiked) in
            if isLiked {
                self.likeButton.isSelected = true
                self.data?.isLiked = true
            } else {
                self.likeButton.isSelected = false
                self.data?.isLiked = false
            }
        }
        
        vc?.loadProfileInformation(setAvatar: { (img) in
            avatarImageView.image = img
            avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        }, setName: { (label) in
            nicknameLabel.text = label
        })
        
        loadImage(url: imageData.url!, progress: { (progress) in
            self.updateProgressView(progress: progress)
        }) { (img, url) in
            if url == self.data?.url {
                self.isLoaded = true
                self.imageView.image = img
            }
        }
    }
    
    func loadImage(url: String, progress: @escaping LoadingProgress, completion: @escaping PhotoLoadingCompletion) {
        isLoaded = false
        vc?.cellIsLoading(url: url, progress: progress, completion: completion)
    }
    
    func updateProgressView(progress: Float) {
        if progress == 1.0 { self.isLoaded = true }
        if self.isLoaded == false {
            self.isLoaded = false
        }
    }
    
    override func prepareForReuse() {
        imageView.image = placeholder
    }
    
    func updateLikesList(photo: Image, setLikesCount: @escaping LikesCountCompletion, setLikeButtonState: @escaping LikeButtonStateCompletion) {
        vc?.fetchLikesList(photo: photo, setLikesCount: setLikesCount, setLikeButtonState: setLikeButtonState)
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        if data?.isLiked == true {
            likeButton.isSelected = false
            vc?.removeLike(photo: data!, completion: { (likes) in
                self.likesCountLabel.text = "\(likes) likes"
            })
        } else {
            likeButton.isSelected = true
            vc?.setLike(photo: data!, completion: { (likes) in
                self.likesCountLabel.text = "\(likes) likes"
            })
        }
    }
}
