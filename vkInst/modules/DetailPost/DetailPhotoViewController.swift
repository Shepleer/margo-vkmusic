//
//  DetailPhotoViewController.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/2/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol DetailPhotoViewControllerProtocol {
    func configureDataSource(comments: [Comment], profiles: [User]?, groups: [Group]?)
}

class DetailPhotoViewController: UIViewController {

    var presenter: DetailPhotoPresenter?
    var postData: Post?
    var profile: User?
    var comments = [Comment]()
    var mediaToPresent = [Any]()
    let placeholder = UIImage(named: "placeholder")
    private var isZooming = false
    private var originalImageCenter: CGPoint?
    
    
    @IBOutlet weak var hearthImageViewWidthAnchor: NSLayoutConstraint!
    @IBOutlet weak var hearthImageViewHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var bigLikeImageView: UIImageView!
    @IBOutlet weak var bigLikeImageWidthAnchor: NSLayoutConstraint!
    @IBOutlet weak var bigLikeImageHeightAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var hearthImageView: UIImageView!
    @IBOutlet weak var mediaContentScrollView: UIScrollView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var topOffset: NSLayoutConstraint!
    @IBOutlet weak var commentFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewsCountLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView! {
        didSet {
            photoImageView.layer.zPosition = -9999
        }
    }
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var sendCommentButton: UIButton!
    @IBOutlet weak var photoContentView: UIView!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var commentField: UIView!
    @IBOutlet weak var commentTextField: UITextField! {
        didSet {
            self.commentTextField.delegate = self
        }
    }
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var invisibleScrollView: UIScrollView! {
        didSet {
            self.invisibleScrollView.delegate = self
        }
    }
    @IBOutlet weak var pageControl: UIPageControl!
    
    let fillHearthImage = UIImage(named: "hearth-red")
    let emptyHearthImage = UIImage(named: "hearth-deselected-black")
    
    
    func configureController(postData: Post, profile: User) {
        self.postData = postData
        self.profile = profile
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            presenter?.invalidateDownloadService()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        loadPhotoAndProfileData()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    
    
    @IBAction func sendCommentButtonTapped(_ sender: UIButton) {
        guard let comment = commentTextField.text,
                let postId = postData?.id,
                let ownerId = postData?.ownerId,
                let profile = profile,
                let name = profile.screenName else { return }
        if comment.isEmpty == false {
                presenter?.sendComment(postId: postId, ownerId: ownerId, commentText: comment)
                let comment = Comment(id: postId, fromId: ownerId, date: nil, text: comment, postId: postId, name: name)
                configureDataSource(comments: [comment], profiles: [profile], groups: nil)
            }
        commentTextField.text = nil
        view.endEditing(true)
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        guard let postId = postData?.id else { return }
        guard let ownerId = postData?.ownerId else { return }
        if likeButton.isSelected {
            startDeselectLikeAnimation()
            presenter?.removeLike(postId: postId, ownerId: ownerId, completion: { (likesCount) in
                self.postData?.isUserLikes = false
                self.postData?.likesCount = likesCount
                self.likeButton.isSelected = false
                self.likesCountLabel.text = "\(likesCount) likes"
            })
        } else {
            startSelectLikeAnimation()
            presenter?.setLike(postId: postId, ownerId: ownerId, completion: { (likesCount) in
                self.postData?.isUserLikes = true
                self.postData?.likesCount = likesCount
                self.likeButton.isSelected = true
                self.likesCountLabel.text = "\(likesCount) likes"
            })
        }
    }
}

extension DetailPhotoViewController: DetailPhotoViewControllerProtocol {
    func configureDataSource(comments: [Comment], profiles: [User]?, groups: [Group]?) {
        var comments = comments
        
        var k = 0
        for comment in comments {
            if let users = profiles {
                if let i = users.firstIndex(where: { (user) -> Bool in
                    user.id == comment.fromId
                }) {
                    comments[i].name = users[i].screenName
                    k += 1
                    continue
                }
            }
            if let groups = groups {
                if let i = groups.firstIndex(where: { (group) -> Bool in
                    return group.id == comment.fromId
                }) {
                    comments[i].name = groups[i].screenName
                    k += 1
                    continue
                }
            }
        }
        
        self.comments.append(contentsOf: comments)
        commentsTableView.reloadSections(IndexSet(integer: 0), with: .fade)
        let scrollViewContentSize = CGSize(width: view.frame.width, height: commentsTableView.contentSize.height + photoContentView.frame.width)
        invisibleScrollView.contentSize = scrollViewContentSize
        presenter?.commentsDownloaded()
    }
}

extension DetailPhotoViewController: UITableViewDelegate {
    
}

extension DetailPhotoViewController: UITextFieldDelegate {
    
}

extension DetailPhotoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "commentCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? DetailPhotoTableViewCell
        cell?.configureCell(data: comments[indexPath.row])
        return cell!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
}

extension DetailPhotoViewController: UIScrollViewDelegate {
    var endScrollRecommendedOffset: CGFloat {
        return commentsTableView.rowHeight * 5
    }
    
    var mediaItemWidth: CGFloat {
        let fullContentWidth = contentStackView.bounds.width
        let itemWidth = fullContentWidth / CGFloat(integerLiteral: pageControl.numberOfPages)
        return itemWidth
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
        if scrollView == invisibleScrollView {
            let contentOffset = scrollView.contentOffset
            topOffset.constant = -contentOffset.y
            
            let currentOffset = scrollView.contentOffset.y + scrollView.frame.size.height
            let maximumOffset = scrollView.contentSize.height
            let deltaOffset = maximumOffset - currentOffset
            if deltaOffset <= endScrollRecommendedOffset {
                guard let id = postData?.id else { return }
                guard let ownerId = postData?.ownerId else { return }
                presenter?.fetchComments(postId: id, ownerId: ownerId)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == mediaContentScrollView {
            let contentOffset = scrollView.contentOffset.x
            let currentPage = (Int(contentOffset) / Int(mediaItemWidth))
            pageControl.currentPage = currentPage
        }
    }
}

extension DetailPhotoViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension DetailPhotoViewController: DownloadMediaProtocol {
    func downloadPhoto(url: String, progress: @escaping DownloadProgress, completion: @escaping PhotoLoadingCompletion) {
        presenter?.downloadPhoto(url: url, progress: progress, completion: completion)
    }
    
    func downloadGif(url: String, progress: @escaping DownloadProgress, completion: @escaping PhotoLoadingCompletion) {
        presenter?.downloadGif(url: url, progress: progress, completion: completion)
    }
}

private extension DetailPhotoViewController {
    
    func loadPhotoAndProfileData() {
        if let photos = postData?.photos {
            for photo in photos {
                mediaToPresent.append(photo)
            }
        }
        if let gifs = postData?.gifs {
            for gif in gifs {
                mediaToPresent.append(gif)
            }
        }
        
        guard let viewsCount = postData?.viewsCount else { return }
        viewsCountLabel.text = "\(viewsCount)"
        guard let likesCount = postData?.likesCount else { return }
        likesCountLabel.text = "\(likesCount) likes"
        nicknameLabel.text = profile?.screenName
        avatarImageView.image = profile?.avatarImage
        view.layoutIfNeeded()
    }
    
    func configureUI() {
        invisibleScrollView.delegate = self
        let scrollViewContentSize = CGSize(width: view.frame.width, height: commentsTableView.contentSize.height + photoContentView.frame.width - 70)
        invisibleScrollView.contentSize = scrollViewContentSize
        view.addGestureRecognizer(invisibleScrollView.panGestureRecognizer)
        self.navigationController?.isNavigationBarHidden = false
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        mediaContentScrollView.isPagingEnabled = true
        commentsTableView.separatorStyle = .none
        
        if postData?.isUserLikes == true {
            likeButton.isSelected = true
            hearthImageView.image = fillHearthImage
        } else {
            likeButton.isSelected = false
            hearthImageView.image = emptyHearthImage
        }
        
        let viewsCount = mediaToPresent.count
        pageControl.numberOfPages = viewsCount
        pageControl.currentPage = 0
        pageControl.hidesForSinglePage = true
        
        for mediaFile in mediaToPresent {
            guard let PhotoContainerView: PhotoContainerView =  PhotoContainerView.fromNib() else { return }
            PhotoContainerView.vc = self
            if let gif = mediaFile as? Gif {
                PhotoContainerView.setMediaContent(mediaFile: gif)
            } else if let image = mediaFile as? Image {
                PhotoContainerView.setMediaContent(mediaFile: image)
            }
            contentStackView.addArrangedSubview(PhotoContainerView)
        }
        
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(scale(sender:)))
        pinchGesture.delaysTouchesEnded = false
        pinchGesture.cancelsTouchesInView = false
        pinchGesture.delaysTouchesBegan = false
        contentStackView.addGestureRecognizer(pinchGesture)
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(sender:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delaysTouchesEnded = false
        doubleTapGesture.delaysTouchesBegan = false
        doubleTapGesture.cancelsTouchesInView = false
        contentStackView.addGestureRecognizer(doubleTapGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(photoScrolled(sender:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        panGesture.cancelsTouchesInView = false
        panGesture.delegate = self
        contentStackView.addGestureRecognizer(panGesture)
    }
    
    @objc func swiped(sender: UISwipeGestureRecognizer) {
        if sender.state == .ended {
            if sender.direction == .right {
                if pageControl.currentPage != 0 {
                    pageControl.currentPage -= 1
                }
            } else if sender.direction == .left {
                if pageControl.numberOfPages > pageControl.currentPage {
                    pageControl.currentPage += 1
                }
            }
        }
    }
    
    
    @objc func doubleTapped(sender: UITapGestureRecognizer) {
        if postData?.isUserLikes == false && sender.state == .ended {
            guard let postId = postData?.id else { return }
            guard let ownerId = postData?.ownerId else { return }
            presenter?.setLike(postId: postId, ownerId: ownerId, completion: { (likesCount) in
                self.postData?.isUserLikes = true
                self.postData?.likesCount = likesCount
                self.likesCountLabel.text = "\(likesCount) likes"
                self.likeButton.isSelected = true
            })
        }
        startSelectLikeAnimation()
        startDoubleTapAnimation()
    }
    
    @objc func scale(sender: UIPinchGestureRecognizer) {
        if sender.state == .began {
            let currentScale = self.contentStackView.frame.size.width / self.contentStackView.bounds.size.width
            let newScale = currentScale*sender.scale
            if newScale > 1 {
                self.isZooming = true
            }
        } else if sender.state == .changed {
            guard let view = sender.view else {return}
            let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
                                      y: sender.location(in: view).y - view.bounds.midY)
            let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: sender.scale, y: sender.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            let currentScale = self.contentStackView.frame.size.width / self.contentStackView.bounds.size.width
            var newScale = currentScale*sender.scale
            if newScale < 1 {
                newScale = 1
                let transform = CGAffineTransform(scaleX: newScale, y: newScale)
                self.contentStackView.transform = transform
                sender.scale = 1
            }else {
                view.transform = transform
                sender.scale = 1
            }
        } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
            UIView.animate(withDuration: 0.3, animations: {
                self.contentStackView.transform = CGAffineTransform.identity
                guard let center = self.originalImageCenter else {return}
                self.contentStackView.center = center
            }, completion: { _ in
                self.isZooming = false
            })
        }
    }
    
    @objc func photoScrolled(sender: UIPanGestureRecognizer) {
        if self.isZooming && sender.state == .began {
            self.originalImageCenter = sender.view?.center
        } else if self.isZooming && sender.state == .changed {
            let translation = sender.translation(in: self.view)
            if let view = sender.view {
                view.center = CGPoint(x:view.center.x + translation.x,
                                      y:view.center.y + translation.y)
            }
            sender.setTranslation(CGPoint.zero, in: self.contentStackView)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        commentFieldBottomConstraint.constant = -keyboardFrame.size.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        commentFieldBottomConstraint.constant = 0
    }
    
    func startDoubleTapAnimation() {
        bigLikeImageWidthAnchor.constant = 70
        bigLikeImageHeightAnchor.constant = 70
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseOut,
                       animations: {
            self.bigLikeImageView.alpha = 1.0
            self.view.layoutIfNeeded()
        }) { (complete) in
            if complete {
                self.bigLikeImageHeightAnchor.constant = 0
                self.bigLikeImageWidthAnchor.constant = 0
                UIView.animateKeyframes(withDuration: 0.2, delay: 0.5, options: .calculationModeLinear, animations: {
                    self.bigLikeImageView.alpha = 0
                    self.view.layoutIfNeeded()
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
                        self.view.layoutIfNeeded()
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
                            self.view.layoutIfNeeded()
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
                        self.view.layoutIfNeeded()
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
                            self.view.layoutIfNeeded()
                            self.hearthImageView.alpha = 1.0
            }, completion: { (complete) in
                
            })
        }
    }
}
