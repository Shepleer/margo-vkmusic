//
//  CollectionViewCell.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/30/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

class TapeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var bigLikeWidthAnchor: NSLayoutConstraint!
    @IBOutlet weak var bigLikeHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var bigLikeImageView: UIImageView!
    @IBOutlet weak var photoHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeightAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var mediaContentStackView: UIStackView! {
        didSet {
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
    @IBOutlet weak var mediaContentScrollView: UIScrollView! {
        didSet {
            mediaContentScrollView.delegate = self
            mediaContentScrollView.isPagingEnabled = true
        }
    }
    @IBOutlet weak var pageControl: UIPageControl!
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
    @IBOutlet weak var hearthImageViewHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var hearthImageViewWidthAnchor: NSLayoutConstraint!
    @IBOutlet weak var hearthImageView: UIImageView!
    @IBOutlet weak var viewsCountImage: UIImageView!
    @IBOutlet weak var postMetadataView: UIView!
    
    
    let fillHearthImage = UIImage(named: "HearthFill")
    let emptyHearthImage = UIImage(named: "HearthDeselected")
    
    weak var vc: ImagesViewController?
    private var progress: DownloadProgress?
    private var completion: LoadingCompletion?
    var data: Post? = nil
    private var isZooming = false
    private var originalImageCenter: CGPoint?
    private var isLoaded = false
    private var isHeightCalculated = false
    
    override func awakeFromNib() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureUI()
    }
    
    func configure(postData: Post) {

        self.data = postData
        setPostMetadata()
        var mediaFiles = [Any]()
        
        vc?.loadProfileInformation(setAvatar: { (img) in
            avatarImageView.image = img
            avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        }, setName: { (label) in
            nicknameLabel.text = label
        })

        if let photos = postData.photos {
            for photo in photos {
                mediaFiles.append(photo)
            }
        }
        if let gifs = postData.gifs {
            for gif in gifs {
                mediaFiles.append(gif)
            }
        }
        pageControl.numberOfPages = mediaFiles.count
        for mediaFile in mediaFiles {
            let PhotoContainerView: PhotoContainerView = .fromNib()
            PhotoContainerView.vc = self
            if let gif = mediaFile as? Gif {
                PhotoContainerView.setMediaContent(mediaFile: gif)
            } else if let image = mediaFile as? Image {
                PhotoContainerView.setMediaContent(mediaFile: image)
            }
            mediaContentStackView.addArrangedSubview(PhotoContainerView)
        }
    }
    
    func updateProgressView(progress: Float) {
        if progress == 1.0 { self.isLoaded = true }
        if self.isLoaded == false {
            self.isLoaded = false
        }
    }
    
    override func prepareForReuse() {
        for subview in mediaContentStackView.subviews {
            subview.removeFromSuperview()
        }
    }
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        if let data = data {
            vc?.moveToDetailPhotoScreen(post: data, currentPage: pageControl.currentPage)
        }
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        guard let postId = data?.id else { return }
        guard let ownerId = data?.ownerId else { return }
        if data?.isUserLikes == true {
            startDeselectLikeAnimation()
            data?.isUserLikes = false
            likeButton.isSelected = false
            vc?.removeLike(postId: postId, ownerId: ownerId, completion: { (likesCount) in
                self.data?.likesCount = likesCount
                self.likesCountLabel.text = "\(likesCount) likes"
            })
        } else {
            startSelectLikeAnimation()
            data?.isUserLikes = true
            likeButton.isSelected = true
            vc?.setLike(postId: postId, ownerId: ownerId, completion: { (likesCount) in
                self.data?.likesCount = likesCount
                self.likesCountLabel.text = "\(likesCount) likes"
            })
        }
    }
    
    func setPostMetadata() {
        guard let isUserLikes = data?.isUserLikes,
            let likesCount = data?.likesCount,
            let viewsCount = data?.viewsCount
            else { return }
        if isUserLikes {
            likeButton.isSelected = true
            hearthImageView.image = fillHearthImage
        } else {
            likeButton.isSelected = false
            hearthImageView.image = emptyHearthImage
        }
        
        likesCountLabel.text = "\(likesCount) likes"
        viewsCountLabel.text = "\(viewsCount)"
    }
    
    func configureUI() {
        let currentTheme = ThemeService.currentTheme()
        let primary = currentTheme.primaryColor
        let secondary = currentTheme.secondaryColor
        let background = currentTheme.backgroundColor
        let secondaryBackground = currentTheme.secondaryBackgroundColor
        
        commentButton.tintColor          = primary
        hearthImageView.tintColor        = primary
        viewsCountImage.tintColor        = primary
        viewsCountLabel.textColor        = primary
        nicknameLabel.textColor          = primary
        profileView.backgroundColor      = background
        postMetadataView.backgroundColor = background
        likesCountLabel.textColor        = primary
        bigLikeImageView.tintColor       = UIColor.white
    }
}

extension TapeCollectionViewCell: UIScrollViewDelegate {
    var mediaItemWidth: CGFloat {
        let fullContentWidth = mediaContentStackView.bounds.width
        let itemWidth = fullContentWidth / CGFloat(integerLiteral: pageControl.numberOfPages)
        return itemWidth
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == mediaContentScrollView {
            let contentOffset = scrollView.contentOffset.x
            let currentPage = (Int(contentOffset) / Int(mediaItemWidth))
            pageControl.currentPage = currentPage
        }
    }
}

extension TapeCollectionViewCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension TapeCollectionViewCell: DownloadMediaProtocol {
    func downloadPhoto(url: String, progress: @escaping DownloadProgress, completion: @escaping PhotoLoadingCompletion) {
        isLoaded = false
        vc?.cellIsLoading(url: url, progress: progress, completion: completion)
    }
    
    func downloadGif(url: String, progress: @escaping DownloadProgress, completion: @escaping PhotoLoadingCompletion) {
        isLoaded = false
        vc?.loadGif(url: url, progress: progress, completion: completion)
    }
}

private extension TapeCollectionViewCell {
    
    
    @objc func tapped(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let location = sender.location(in: self)
            if mediaContentStackView.frame.contains(location) {
                if data?.isUserLikes == false {
                    guard let postId = data?.id else { return }
                    guard let ownerId = data?.ownerId else { return }
                    vc?.setLike(postId: postId, ownerId: ownerId, completion: { (likesCount) in
                        self.data?.isUserLikes = true
                        self.likeButton.isSelected = true
                        self.likesCountLabel.text = "\(likesCount) likes"
                    })
                }
                startDoubleTapAnimation()
                startSelectLikeAnimation()
            }
        }
    }
    
    @objc func scaled(sender: UIPinchGestureRecognizer) {
        let location = sender.location(in: self)
        if mediaContentStackView.frame.contains(location) {
            if sender.state == .began {
                vc?.disableScrollView()
                let currentState = self.mediaContentStackView.frame.width / self.mediaContentStackView.bounds.width
                let newScale = currentState * sender.scale
                if newScale > 1 { self.isZooming = true }
            } else if sender.state == .changed {
                let pinchCenter = CGPoint(x: sender.location(in: mediaContentStackView).x - mediaContentStackView.bounds.midX,
                                          y: sender.location(in: mediaContentStackView).y - mediaContentStackView.bounds.midY)
                let transform = mediaContentStackView.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                    .scaledBy(x: sender.scale, y: sender.scale)
                    .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                let currentScale = self.mediaContentStackView.frame.width / self.mediaContentStackView.bounds.width
                var newScale = currentScale * sender.scale
                if newScale < 1 {
                    newScale = 1
                    let transform = CGAffineTransform(scaleX: newScale, y: newScale)
                    self.mediaContentStackView.transform = transform
                    sender.scale = 1
                } else {
                    mediaContentStackView.transform = transform
                    sender.scale = 1
                }
            } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
                vc?.enableScrollView()
                UIView.animate(withDuration: 0.3, animations: {
                    self.mediaContentStackView.transform = CGAffineTransform.identity
                    guard let center = self.originalImageCenter else { return }
                    self.mediaContentStackView.center = center
                    
                }) { _ in
                    self.isZooming = false
                }
            }
        }
    }
    
    
    @objc func imageViewScrolled(sender: UIPanGestureRecognizer) {
        if self.isZooming && sender.state == .began {
            self.originalImageCenter = mediaContentStackView.center
        } else if self.isZooming && sender.state == .changed {
            let translation = sender.translation(in: mediaContentStackView.superview)
            if let view = mediaContentStackView {
                view.center = CGPoint(x: mediaContentStackView.center.x + translation.x, y: mediaContentStackView.center.y + translation.y)
            }
            sender.setTranslation(CGPoint.zero, in: self)
        }
    }
    
    func startDoubleTapAnimation() {
        bigLikeWidthAnchor.constant = 70
        bigLikeHeightAnchor.constant = 70
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        self.bigLikeImageView.alpha = 0.7
                        self.layoutIfNeeded()
        }) { (complete) in
            if complete {
                self.bigLikeHeightAnchor.constant = 0
                self.bigLikeWidthAnchor.constant = 0
                UIView.animateKeyframes(withDuration: 0.2,
                                        delay: 0.5,
                                        options: .calculationModeLinear,
                                        animations: {
                                            self.bigLikeImageView.alpha = 0
                                            self.layoutIfNeeded()
                }, completion: { (complete) in
                })
            }
        }
    }
    
    func startDeselectLikeAnimation() {
        hearthImageViewWidthAnchor.constant = 0
        hearthImageViewHeightAnchor.constant = 0
        UIView.animate(withDuration: 0.15,
                       delay: 0.1,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        self.layoutIfNeeded()
                        self.hearthImageView.alpha = 0
        }) { (complete) in
            self.hearthImageView.image = self.emptyHearthImage
            self.hearthImageViewHeightAnchor.constant = 25
            self.hearthImageViewWidthAnchor.constant = 25
            UIView.animate(withDuration: 0.15,
                           delay: 0.0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.0,
                           options: .curveEaseOut,
                           animations: {
                            self.layoutIfNeeded()
                            self.hearthImageView.alpha = 1.0
            }, completion: { (complete) in
                
            })
        }
    }
    
    func startSelectLikeAnimation() {
        hearthImageViewWidthAnchor.constant = 0
        hearthImageViewHeightAnchor.constant = 0
        UIView.animate(withDuration: 0.15,
                       delay: 0.1,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        self.layoutIfNeeded()
                        self.hearthImageView.alpha = 0.5
        }) { (complete) in
            self.hearthImageView.image = self.fillHearthImage
            self.hearthImageViewHeightAnchor.constant = 25
            self.hearthImageViewWidthAnchor.constant = 25
            UIView.animate(withDuration: 0.15,
                           delay: 0.0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: 0.0,
                           options: .curveEaseOut,
                           animations: {
                            self.layoutIfNeeded()
                            self.hearthImageView.alpha = 1.0
            }, completion: { (complete) in
                
            })
        }
    }
}
