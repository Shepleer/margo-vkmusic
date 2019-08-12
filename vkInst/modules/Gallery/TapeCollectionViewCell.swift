//
//  CollectionViewCell.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/30/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

class TapeCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var viewsCountLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.zPosition = -1
            let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped(sender:)))
            doubleTapGesture.numberOfTapsRequired = 2
            self.addGestureRecognizer(doubleTapGesture)
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(scaled(sender:)))
            self.addGestureRecognizer(pinchGesture)
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(imageViewScrolled(sender:)))
            panGesture.delegate = self
            self.addGestureRecognizer(panGesture)
        }
    }
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesCountLabel: UILabel!

    @IBOutlet weak var profileView: TapeCollectionViewCell! 
    
    @IBOutlet weak var commentButton: UIButton!
    
    weak var vc: ImagesViewController?
    private var progress: LoadingProgress?
    private var completion: LoadingCompletion?
    var data: Post? = nil
    private var isZooming = false
    private var originalImageCenter: CGPoint?
    private let placeholder = UIImage(named: "placeholder")
    private var isLoaded = false
    private var isHeightCalculated = false
    
    override func awakeFromNib() {

    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()
        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
        var newFrame = layoutAttributes.bounds
        newFrame.size.height = CGFloat(ceilf(Float(size.height)))
        newFrame.size.height = size.height
        layoutAttributes.bounds = newFrame
        return layoutAttributes
    }
    
    func configure(postData: Post) {
        guard postData.photos?.first?.url != data?.photos?.first?.url else { return }
        self.data = postData
        imageView.image = placeholder
        
        if postData.isUserLikes == true {
            likeButton.isSelected = true
        } else {
            likeButton.isSelected = false
        }
        if let likesCount = postData.likesCount {
            likesCountLabel.text = "\(likesCount) likes"
        }
        
        if let viewsCount = postData.viewsCount {
            viewsCountLabel.text = "\(viewsCount)"
        }
        
        vc?.loadProfileInformation(setAvatar: { (img) in
            avatarImageView.image = img
            avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        }, setName: { (label) in
            nicknameLabel.text = label
        })
        
        /*
        guard let photos = postData.photos else { return }
        for photo in photos {
            if let originalUrl = photo.url {
                loadImage(url: originalUrl, progress: { (progress) in

                }) { (img, url) in
                    if url == originalUrl {
                        self.data?.photos
                        //god help me
                    }
                }
            }
        }
        */
        
        guard let url = postData.photos?.first?.url else { return }
        
        loadImage(url: url, progress: { (progress) in
            self.updateProgressView(progress: progress)
        }) { (img, url) in
            if url == self.data?.photos?.first?.url {
                self.data?.photos?[0].img = img
                self.isLoaded = true
                self.imageView.image = img
            }
        }
    }
    
    func loadImage(url: String, progress: @escaping LoadingProgress, completion: @escaping PhotoLoadingCompletion) {
        isLoaded = false
        vc?.cellIsLoading(url: url, progress: progress, completion: completion)
    }
    
    func fetchPhotoComments() {
        guard let postId = data?.id else { return }
        guard let ownerId = data?.ownerId else { return }
        vc?.fetchPostData(postId: postId, ownerId: ownerId, completion: { (response) in
            guard let comments = response?.comments else { return }
            if comments.isEmpty {
                self.commentLabel.isHidden = true
            } else {
                self.commentLabel.isHidden = false
                guard let text = comments.first?.text else { return }
                self.commentLabel.text = text
            }
        })
    }
    
    func updateProgressView(progress: Float) {
        if progress == 1.0 { self.isLoaded = true }
        if self.isLoaded == false {
            self.isLoaded = false
        }
    }
    
    override func prepareForReuse() {
    }
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        if let data = data {
            vc?.moveToDetailPhotoScreen(post: data)
        }
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        guard let postId = data?.id else { return }
        guard let ownerId = data?.ownerId else { return }
        if data?.isUserLikes == true {
            data?.isUserLikes = false
            likeButton.isSelected = false
            vc?.removeLike(postId: postId, ownerId: ownerId, completion: { (likesCount) in
                self.data?.likesCount = likesCount
                self.likesCountLabel.text = "\(likesCount) likes"
            })
        } else {
            data?.isUserLikes = true
            likeButton.isSelected = true
            vc?.setLike(postId: postId, ownerId: ownerId, completion: { (likesCount) in
                self.data?.likesCount = likesCount
                self.likesCountLabel.text = "\(likesCount) likes"
            })
        }
    }
    
    @objc func tapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let location = sender.location(in: self)
            if imageView.frame.contains(location) {
                if data?.isUserLikes == false {
                    guard let postId = data?.id else { return }
                    guard let ownerId = data?.ownerId else { return }
                    vc?.setLike(postId: postId, ownerId: ownerId, completion: { (likesCount) in
                        self.data?.isUserLikes = true
                        self.likeButton.isSelected = true
                        self.likesCountLabel.text = "\(likesCount) likes"
                    })
                }
            }
        }
    }
    
    @objc func scaled(sender: UIPinchGestureRecognizer) {
        let location = sender.location(in: self)
        if imageView.frame.contains(location) {
            if sender.state == .began {
                vc?.disableScrollView()
                let currentState = self.imageView.frame.width / self.imageView.bounds.width
                let newScale = currentState * sender.scale
                if newScale > 1 { self.isZooming = true }
            } else if sender.state == .changed {
                let pinchCenter = CGPoint(x: sender.location(in: imageView).x - imageView.bounds.midX,
                                          y: sender.location(in: imageView).y - imageView.bounds.midY)
                let transform = imageView.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                                                                .scaledBy(x: sender.scale, y: sender.scale)
                                                                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                let currentScale = self.imageView.frame.width / self.imageView.bounds.width
                var newScale = currentScale * sender.scale
                if newScale < 1 {
                    newScale = 1
                    let transform = CGAffineTransform(scaleX: newScale, y: newScale)
                    self.imageView.transform = transform
                    sender.scale = 1
                } else {
                    imageView.transform = transform
                    sender.scale = 1
                }
            } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
                vc?.enableScrollView()
                UIView.animate(withDuration: 0.3, animations: {
                    self.imageView.transform = CGAffineTransform.identity
                    guard let center = self.originalImageCenter else { return }
                    self.imageView.center = center
                }) { _ in
                    self.isZooming = false
                }
            }
        }
    }
    
    
    @objc func imageViewScrolled(sender: UIPanGestureRecognizer) {
        if self.isZooming && sender.state == .began {
            self.originalImageCenter = sender.view?.center
        } else if self.isZooming && sender.state == .changed {
            let translation = sender.translation(in: imageView.superview)
            if let view = imageView {
                view.center = CGPoint(x: imageView.center.x + translation.x, y: imageView.center.y + translation.y)
            }
            sender.setTranslation(CGPoint.zero, in: self)
        }
    }
}

extension TapeCollectionViewCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
