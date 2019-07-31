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
    
    public typealias LoadingProgress = ((_ progress: Float) -> ())
    public typealias LoadingCompletion = ((_ image: UIImage) -> ())
    
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
            //label.text = "\(likes) likes"
        }) { (isLiked) in
            if isLiked {
                //button.color = red
            } else {
                
            }
        }
        
        vc?.loadProfileInformation(setAvatar: { (img) in
            avatarImageView.image = img
            avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        }, setName: { (label) in
            nicknameLabel.text = label
        })
        
        loadImage(url: imageData.url!, progress: { (progress) in
            DispatchQueue.main.async {
                self.updateProgressView(progress: progress)
            }
        }) { (img, url) in
            DispatchQueue.main.async {
                if url == self.data?.url {
                    self.isLoaded = true
                    self.imageView.image = img
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
        }
    }
    
    override func prepareForReuse() {
        imageView.image = placeholder
    }
    
    func updateLikesList(photo: Image, setLikesCount: @escaping (_ likes: Int) -> (), setLikeButtonStatew: @escaping (_ isLiked: Bool) -> ()) {
        
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        vc?.setLike(photo: data!)
    }
}
