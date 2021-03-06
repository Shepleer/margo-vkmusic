//
//  DetailPhotoViewController.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/2/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol DetailPostViewControllerProtocol: class {
    func configureDataSource(comments: [Comment], profiles: [User]?, groups: [Group]?)
    func showError(error: Error)
}

class DetailPostViewController: UIViewController {

    private struct Constants {
        static let activeBigLikeSizeAnchor = CGFloat(70.0)
        static let activeLikeSizeAnchor = CGFloat(25.0)
        static let bigLikeAnimationDuration = 0.4
        static let likeAnimationDuration = 0.15
        static let animationSpringWithDamping = CGFloat(0.5)
        static let selectLikeAnimationDelay = 0.1
        static let animationLikeAlpha = CGFloat(0.5)
        static let activeBigLikeAlpha = CGFloat(0.7)
        static let hideBigLikeAnimationDuration = 0.2
        static let summaryRowHeightMultiplier = CGFloat(5)
        static let numberOfSections = 1
        static let scaleEndAnimationDuration = 0.3
        static let likesCountLabel = "likes"
        static let commentCellIdentifiet = "commentCell"
        static let fillHearthImage = UIImage(named: "HearthFill")
        static let emptyHearthImage = UIImage(named: "HearthDeselected")
        static let internetConnectionErrorDescribtion = "Internet connection are not available"
    }
    
    
    var presenter: DetailPostPresenter?
    var postData: Post?
    var profile: User?
    var comments = [Comment]()
    var mediaToPresent = [Any]()
    private var isZooming = false
    private var originalImageCenter: CGPoint?
    private var currentPage = 0
    private var isErrorPresenting = false
    
    private lazy var mediaItemWidth: CGFloat = {
        let fullContentWidth = contentStackView.bounds.width
        let itemWidth = fullContentWidth / CGFloat(integerLiteral: pageControl.numberOfPages)
        return itemWidth
    }()
    
    var refreshControll = UIRefreshControl()
    @IBOutlet weak var hearthImageViewWidthAnchor: NSLayoutConstraint!
    @IBOutlet weak var hearthImageViewHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var bigLikeImageView: UIImageView!
    @IBOutlet weak var bigLikeImageWidthAnchor: NSLayoutConstraint!
    @IBOutlet weak var bigLikeImageHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var contentWidhtAnchor: NSLayoutConstraint!
    
    @IBOutlet weak var hearthImageView: UIImageView!
    @IBOutlet weak var mediaContentScrollView: UIScrollView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var topOffset: NSLayoutConstraint!
    @IBOutlet weak var commentFieldBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewsCountLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var photoImageView: UIImageView!
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
    @IBOutlet weak var profileMetadataView: UIView!
    @IBOutlet weak var postMetadataView: UIView!
    @IBOutlet weak var viewsCountImage: UIImageView!
    
    func configureController(postData: Post, currentPage: Int, profile: User) {
        self.postData = postData
        self.profile = profile
        self.currentPage = currentPage
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        guard parent == nil,
            let galleryViewController = navigationController?.viewControllers.first as? GalleryViewControllerProtocol else { return }
        galleryViewController.updateOffset()
        presenter?.invalidateDownloadService()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        loadPhotoAndProfileData()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configurePresentation()
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
            startLikeAnimation(setLike: false)
            presenter?.removeLike(postId: postId, ownerId: ownerId, completion: { [weak self] (likesCount, error, url) in
                guard let self = self else { return }
                if let likesCount = likesCount {
                    self.postData?.isUserLikes = false
                    self.postData?.likesCount = likesCount
                    self.likeButton.isSelected = false
                    self.likesCountLabel.text = "\(likesCount) \(Constants.likesCountLabel)"
                    self.updatePostData()
                } else if let error = error {
                    self.showError(error: error)
                }
            })
        } else {
            startLikeAnimation(setLike: true)
            presenter?.setLike(postId: postId, ownerId: ownerId, completion: { (likesCount, error, url) in
                if let likesCount = likesCount {
                    self.postData?.isUserLikes = true
                    self.postData?.likesCount = likesCount
                    self.likeButton.isSelected = true
                    self.likesCountLabel.text = "\(likesCount) \(Constants.likesCountLabel)"
                    self.updatePostData()
                } else if let error = error {
                    self.showError(error: error)
                }
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateImagesWidth()
    }
}

extension DetailPostViewController: DetailPostViewControllerProtocol {
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
        let scrollViewContentSize = CGSize(width: view.frame.width, height: commentsTableView.contentSize.height + profileMetadataView.frame.size.height + postMetadataView.frame.size.height + mediaContentScrollView.frame.size.height)
        invisibleScrollView.contentSize = scrollViewContentSize
        presenter?.commentsDownloaded()
    }
    
    func showError(error: Error) {
        if let error = error as? RequestError {
            isErrorPresenting = true
            if error.apiError?.errorCode == 14 {
                let captchaView: CaptchaView = .fromNib()
                view.addSubview(captchaView)
            } else if let errorDescription = error.errorDescription {
                showToast(message: errorDescription, completion: { [weak self] in
                    guard let self = self else { return }
                    self.isErrorPresenting = false
                })
            }
        }
    }
}

extension DetailPostViewController: UITableViewDelegate {
    
}

extension DetailPostViewController: UITextFieldDelegate {
    
}

extension DetailPostViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.commentCellIdentifiet, for: indexPath) as? DetailPostTableViewCell else { fatalError() }
        cell.configureCell(data: comments[indexPath.row])
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Constants.numberOfSections
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
}

extension DetailPostViewController: UIScrollViewDelegate {
    var endScrollRecommendedOffset: CGFloat {
        return commentsTableView.rowHeight * Constants.summaryRowHeightMultiplier
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
        guard scrollView == invisibleScrollView else { return }
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        view.endEditing(true)
        guard scrollView == mediaContentScrollView else { return }
        let contentOffset = scrollView.contentOffset.x
        let currentPage = (Int(contentOffset) / Int(mediaItemWidth))
        pageControl.currentPage = currentPage
    }
}

extension DetailPostViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension DetailPostViewController: DownloadMediaProtocol {
    func downloadPhoto(url: String, progress: @escaping DownloadProgress, completion: @escaping MediaLoadingCompletion) {
        presenter?.downloadPhoto(url: url, progress: progress, completion: completion)
    }
    
    func downloadGif(url: String, progress: @escaping DownloadProgress, completion: @escaping MediaLoadingCompletion) {
        presenter?.downloadGif(url: url, progress: progress, completion: completion)
    }
}

private extension DetailPostViewController {
    
    func updateImagesWidth() {
        for view in contentStackView.arrangedSubviews {
            if let photoContainer = view as? PhotoContainerView {
                photoContainer.imageWidthAnchor.constant = self.view.frame.size.width
            }
        }
        contentStackView.layoutIfNeeded()
    }
    
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
        likesCountLabel.text = "\(likesCount) \(Constants.likesCountLabel)"
        nicknameLabel.text = profile?.screenName
        avatarImageView.image = profile?.avatarImage
        view.layoutIfNeeded()
    }
    
    func configureUI() {
        invisibleScrollView.delegate = self
        let scrollViewContentSize = CGSize(width: view.frame.width, height: commentsTableView.contentSize.height + photoContentView.frame.height)
        invisibleScrollView.contentSize = scrollViewContentSize
        invisibleScrollView.refreshControl = refreshControll
        refreshControll.addTarget(self, action: #selector(refreshPostMetadata(sender:)), for: .valueChanged)
        view.addGestureRecognizer(invisibleScrollView.panGestureRecognizer)
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        mediaContentScrollView.isPagingEnabled = true
        commentsTableView.separatorStyle = .none
        
        if postData?.isUserLikes == true {
            likeButton.isSelected = true
            hearthImageView.image = Constants.fillHearthImage
        } else {
            likeButton.isSelected = false
            hearthImageView.image = Constants.emptyHearthImage
        }
        
        let viewsCount = mediaToPresent.count
        pageControl.numberOfPages = viewsCount
        pageControl.currentPage = 0
        pageControl.hidesForSinglePage = true
        
        fillMediaStackView()
        
        pageControl.currentPage = currentPage
        let offset = contentStackView.bounds.size.width * CGFloat(integerLiteral: currentPage)
        mediaContentScrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: false)
        
        buildDoubleTapGesture()
        buildPinchGesture()
        buildPanGesture()
        
        if !Reachability.isConnectedToNetwork() {
            isErrorPresenting = true
            showToast(message: Constants.internetConnectionErrorDescribtion, completion: { [weak self] in
                guard let self = self else { return }
                self.isErrorPresenting = false
            })
        }
    }
    
    func configurePresentation() {
        let currentTheme = ThemeService.currentTheme()
        let primary = currentTheme.primaryColor
        let secondary = currentTheme.secondaryColor
        let background = currentTheme.backgroundColor
        let secondaryBackground = currentTheme.secondaryBackgroundColor
        let placeholder = NSAttributedString(string: "Write here", attributes: [NSAttributedString.Key.foregroundColor: secondary])
        navigationController?.isNavigationBarHidden = false
        
        profileMetadataView.backgroundColor            = background
        postMetadataView.backgroundColor               = background
        commentsTableView.backgroundColor              = background
        view.backgroundColor                           = background
        commentField.backgroundColor                   = background
        commentTextField.backgroundColor               = secondaryBackground
        commentTextField.attributedPlaceholder         = placeholder
        commentTextField.textColor                     = primary
        viewsCountImage.tintColor                      = primary
        commentButton.tintColor                        = primary
        hearthImageView.tintColor                      = primary
        sendCommentButton.tintColor                    = primary
        bigLikeImageView.tintColor                     = UIColor.white
        viewsCountLabel.textColor                      = primary
        likesCountLabel.textColor                      = primary
        nicknameLabel.textColor                        = primary
    }
    
    func fillMediaStackView() {
        for mediaFile in mediaToPresent {
            let photoContainerView: PhotoContainerView =  PhotoContainerView.fromNib()
            photoContainerView.cell = self
            if let gif = mediaFile as? Gif {
                photoContainerView.setMediaContent(mediaFile: gif)
            } else if let image = mediaFile as? Image {
                photoContainerView.setMediaContent(mediaFile: image)
            }
            contentStackView.addArrangedSubview(photoContainerView)
        }
    }
    
    func updatePostData() {
        guard let galleryViewController = navigationController?.viewControllers.first as? GalleryViewControllerProtocol,
            let id = postData?.id,
            let likesCount = postData?.likesCount,
            let isUserLikes = postData?.isUserLikes else { return }
        galleryViewController.updatePostData(postId: id, likesCount: likesCount, isUserLikes: isUserLikes)
    }
    
    func buildDoubleTapGesture() {
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(sender:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delaysTouchesEnded = false
        doubleTapGesture.delaysTouchesBegan = false
        doubleTapGesture.cancelsTouchesInView = false
        contentStackView.addGestureRecognizer(doubleTapGesture)
    }
    
    func buildPinchGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(scale(sender:)))
        pinchGesture.delaysTouchesEnded = false
        pinchGesture.cancelsTouchesInView = false
        pinchGesture.delaysTouchesBegan = false
        contentStackView.addGestureRecognizer(pinchGesture)
    }
    
    func buildPanGesture() {
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
            presenter?.setLike(postId: postId, ownerId: ownerId, completion: { [weak self] (likesCount, error, url) in
                guard let self = self else { return }
                if let likesCount = likesCount {
                    self.postData?.isUserLikes = true
                    self.postData?.likesCount = likesCount
                    self.likesCountLabel.text = "\(likesCount) \(Constants.likesCountLabel)"
                    self.likeButton.isSelected = true
                } else if let error = error {
                    self.showError(error: error)
                }
            })
        }
        startLikeAnimation(setLike: true)
        startBigLikeAppearAnimation()
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
            UIView.animate(withDuration: Constants.scaleEndAnimationDuration, animations: {
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
    
    @objc func refreshPostMetadata(sender: UIRefreshControl) {
        comments.removeAll()
        commentsTableView.reloadData()
        for view in contentStackView.subviews {
            view.removeFromSuperview()
        }
        presenter?.refreshData()
        currentPage = 0
        pageControl.currentPage = 0
        guard let postId = postData?.id,
            let ownerId = profile?.id else { return }
        presenter?.fetchComments(postId: postId, ownerId: ownerId)
        presenter?.fetchPostMetadata(postId: postId, completion: { [weak self] (post, error, url) in
            guard let self = self else { return }
            self.postData = post
            self.fillMediaStackView()
            self.loadPhotoAndProfileData()
            sender.endRefreshing()
        })
    }
    
    func startBigLikeAppearAnimation() {
        bigLikeImageWidthAnchor.constant = Constants.activeBigLikeSizeAnchor
        bigLikeImageHeightAnchor.constant = Constants.activeBigLikeSizeAnchor
        UIView.animate(withDuration: Constants.bigLikeAnimationDuration,
                       delay: 0,
                       usingSpringWithDamping: Constants.animationSpringWithDamping,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseOut,
                       animations: {
            self.bigLikeImageView.alpha = Constants.activeBigLikeAlpha
            self.view.layoutIfNeeded()
        }) { (complete) in
            if complete {
                self.bigLikeImageHeightAnchor.constant = 0
                self.bigLikeImageWidthAnchor.constant = 0
                UIView.animateKeyframes(withDuration: Constants.hideBigLikeAnimationDuration,
                                        delay: Constants.selectLikeAnimationDelay,
                                        options: .calculationModeLinear, animations: {
                    self.bigLikeImageView.alpha = 0
                    self.view.layoutIfNeeded()
                }, completion: { (complete) in
                })
            }
        }
    }
    
    func startLikeAnimation(setLike: Bool) {
        hearthImageViewWidthAnchor.constant = 0
        hearthImageViewHeightAnchor.constant = 0
        UIView.animate(withDuration: Constants.likeAnimationDuration,
                       delay: Constants.selectLikeAnimationDelay,
                       usingSpringWithDamping: Constants.animationSpringWithDamping,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        self.view.layoutIfNeeded()
                        if setLike {
                            self.hearthImageView.alpha = Constants.animationLikeAlpha
                        } else {
                            self.hearthImageView.alpha = 0
                        }
        }) { (complete) in
            if setLike {
                self.hearthImageView.image = Constants.fillHearthImage
            } else {
                self.hearthImageView.image = Constants.emptyHearthImage
            }
            self.hearthImageViewHeightAnchor.constant = Constants.activeLikeSizeAnchor
            self.hearthImageViewWidthAnchor.constant = Constants.activeLikeSizeAnchor
            UIView.animate(withDuration: Constants.likeAnimationDuration,
                           delay: 0.0,
                           usingSpringWithDamping: Constants.animationSpringWithDamping,
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
