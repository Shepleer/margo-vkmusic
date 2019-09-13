//
//  MusicPlayerViewController.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/2/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol GalleryViewControllerProtocol: class {
    func configureWithPhotos(posts: [Post])
    func loadAvatar(image: UIImage)
    func setProfileData(user: User)
    func setLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion)
    func removeLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion)
    func fetchPostData(postId: Int, ownerId: Int, completion: @escaping CommentsCompletion)
    func moveToDetailPhotoScreen(post: Post, currentPage: Int)
    func viewControllerWillReleased()
    func insertNewPost(post: Post)
    func updatePostData(postId: Int, likesCount: Int, isUserLikes: Bool)
    func updateOffset()
}

protocol GalleryViewControllerCellDelegate: class {
    func disableScrollView()
    func enableScrollView()
    func cellIsLoading(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ())
    func loadGif(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ())
    func setLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion)
    func removeLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion)
    func moveToDetailPhotoScreen(post: Post, currentPage: Int)
    func loadProfileInformation(setAvatar: (_ avatar: UIImage) -> (), setName: (_ label: String) -> ())
    func fetchPostData(postId: Int, ownerId: Int, completion: @escaping CommentsCompletion)
}

class GalleryViewController: UIViewController {
    private struct Constants {
        static let animationDuration = 0.1
        static let gridItemIdentifier = "imgCell"
        static let tapeItemIdentifier = "bigCell"
        static let galleryCollectionViewFooterIdentifier = "photosFooter"
        static let galleryCollectionFooterView = "GalleryCollectionFooterView"
        static let rotationKeyPath = "transform.rotation"
        static let rotationAnimationKey = "viewRotation"
        static let highlightedItemOpacity = Float(0.5)
        static let normalItemOpacity = Float(1)
        static let shadowRadius = CGFloat(30)
        static let recomendetOffsetMultiplier = CGFloat(4)
        static let footerViewHeight = CGFloat(50)
        static let changeTapsAnimationDuration = 0.3
        static let deselectedTapAlpha = CGFloat(0.5)
        static let addPostViewShadowRadius = CGFloat(2)
        static let defaultShadowOpacity = Float(0.2)
        static let shadowOffsetWidth = CGFloat(5)
        static let shadowOffsetHeightMultiplier = CGFloat(3)
        static let internetConnectionErrorMessage = "Internet connection are not available"
    }
    
    
    var presenter: GalleryPresenterProtocol?
    var flowLayout: GridCollectionViewFlowLayout = GridCollectionViewFlowLayout()
    var tapeFlowLayout: TapeCollectionViewFlowLayout = TapeCollectionViewFlowLayout()
    var posts = [Post]()
    var profile: User? = nil
    var avatarImage: UIImage? = nil
    var offset: Int = 0
    var openedCellIndex: Int = 0
    
    private var proposedContentOffset: CGPoint? = nil
    
    private var refreshControl = UIRefreshControl()
    @IBOutlet weak var activityViewTopOffset: NSLayoutConstraint!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var addPostButton: UIButton!
    @IBOutlet weak var headerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var secondHeaderBottom: NSLayoutConstraint!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var friendsCountLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var secondHeaderView: UIView!
    @IBOutlet weak var topOffset: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var gridModeButton: UIButton!
    @IBOutlet weak var tapeModeButton: UIButton!
    @IBOutlet weak var addPostView: UIView!
    @IBOutlet weak var friendsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var tapeStateIndicator: UIView!
    @IBOutlet weak var gridStateIndicator: UIView!
    @IBOutlet weak var imageCollectionView: UICollectionView! {
        didSet {
            imageCollectionView.delegate = self
        }
    }
    @IBOutlet weak var mainScrollView: UIScrollView! {
        didSet {
            mainScrollView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        configureUI()
        presenter?.nextFetch()
        imageCollectionView.register(UINib(nibName: Constants.galleryCollectionFooterView, bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: Constants.galleryCollectionViewFooterIdentifier)
        flowLayout.vc = self
        tapeFlowLayout.vc = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configurePresentation()
    }
    
    func cancellingDownload(image: Image) {
        presenter?.cancelDownload(image: image)
    }
    
    @IBAction func curveButtonDidPressed(_ sender: UIButton) {
        let rotationAnimation = CABasicAnimation(keyPath: Constants.rotationKeyPath)
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Float.pi * 2.0
        rotationAnimation.duration = 1.5
        rotationAnimation.repeatCount = Float.infinity
        self.view.layer.add(rotationAnimation, forKey: Constants.rotationAnimationKey)
        followersCountLabel.layer.add(rotationAnimation, forKey: Constants.rotationAnimationKey)
        friendsCountLabel.layer.add(rotationAnimation, forKey: Constants.rotationAnimationKey)
        avatarImageView.layer.add(rotationAnimation, forKey: Constants.rotationAnimationKey)
        secondHeaderView.layer.add(rotationAnimation, forKey: Constants.rotationAnimationKey)
        headerView.layer.add(rotationAnimation, forKey: Constants.rotationAnimationKey)
        gridModeButton.layer.add(rotationAnimation, forKey: Constants.rotationAnimationKey)
        tapeModeButton.layer.add(rotationAnimation, forKey: Constants.rotationAnimationKey)
        for cell in imageCollectionView.visibleCells {
            cell.layer.add(rotationAnimation, forKey: Constants.rotationAnimationKey)
        }
    }
    
    @IBAction func settingsButtonTapped(_ sender: UIButton) {
        presenter?.moveToSettingsScreen()
    }
    
    @IBAction func gridModeButtonTapped(_ sender: UIButton) {
        setGridMode()
    }
    
    @IBAction func tapeModeButtonTapped(_ sender: UIButton) {
        setTapeMode()
        imageCollectionView.reloadData()
    }
    
    @IBAction func uploadPostButtonPressed(_ sender: UIButton) {
        presenter?.moveToUploadPostScreen()
    }
}

extension GalleryViewController: GalleryViewControllerCellDelegate {
    func disableScrollView() {
        mainScrollView.isScrollEnabled = false
    }
    
    func enableScrollView() {
        mainScrollView.isScrollEnabled = true
    }
    
    func cellIsLoading(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ()) {
        presenter?.loadImage(url: url, progress: progress, completion: completion)
    }
    
    func loadGif(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ()) {
        presenter?.loadGif(url: url, progress: progress, completion: completion)
    }
    
    func setLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion) {
        presenter?.setLike(postId: postId, ownerId: ownerId, completion: completion)
    }
    
    func removeLike(postId: Int, ownerId: Int, completion: @escaping LikesCountCompletion) {
        presenter?.removeLike(postId: postId, ownerId: ownerId, completion: completion)
    }
    
    func moveToDetailPhotoScreen(post: Post, currentPage: Int) {
        guard var profile = profile else { return }
        profile.avatarImage = avatarImage
        presenter?.moveToDetailScreen(post: post, currentPage: currentPage, profile: profile)
    }
    
    func loadProfileInformation(setAvatar: (_ avatar: UIImage) -> (), setName: (_ label: String) -> ()) {
        if let img = avatarImageView.image {
            setAvatar(img)
        }
        if let nickname = profile?.screenName {
            setName(nickname)
            return
        }
        if let firstName = profile?.firstName {
            setName(firstName)
        }
    }
    
    func fetchPostData(postId: Int, ownerId: Int, completion: @escaping CommentsCompletion) {
        presenter?.fetchComments(postId: postId, ownerId: ownerId, completion: completion)
    }
}

extension GalleryViewController: GalleryViewControllerProtocol {
    func updatePostData(postId: Int, likesCount: Int, isUserLikes: Bool) {
        guard let visibleCells = imageCollectionView.visibleCells as? [TapeCollectionViewCell] else { return }
        for item in visibleCells {
            if postId == item.data?.id && likesCount != item.data?.likesCount && item.data?.isUserLikes != isUserLikes {
                item.data?.isUserLikes = isUserLikes
                item.data?.likesCount = likesCount
                item.setPostMetadata()
            }
        }
    }
    
    func updateOffset() {
        mainScrollView.contentOffset = imageCollectionView.contentOffset
    }
    
    func configureWithPhotos(posts: [Post]) {
        self.posts.append(contentsOf: posts)
        let startOffset = offset
        offset = self.posts.count
        var indexPaths = [IndexPath]()
        for i in startOffset...offset - 1 {
            indexPaths.append(IndexPath(item: i, section: 0))
        }
        imageCollectionView.performBatchUpdates({
            imageCollectionView.insertItems(at: indexPaths)
        }) { (complete) in
        }
        let scrollViewContentSize = CGSize(width: view.frame.width, height: headerView.frame.height + headerViewBottom.accessibilityFrame.height + secondHeaderView.frame.height + secondHeaderBottom.accessibilityFrame.height + imageCollectionView.collectionViewLayout.collectionViewContentSize.height)
        mainScrollView.contentSize = scrollViewContentSize
        presenter?.postsDownloaded()
    }
    
    func loadAvatar(image: UIImage) {
        avatarImageView.image = image
        UIView.animate(withDuration: Constants.animationDuration) {
            self.avatarImageView.alpha = 1
        }
        avatarImage = image
    }
    
    func setProfileData(user: User) {
        profile = user
        if let friends = user.counters?.friends {
            friendsCountLabel.text = "\(friends)"
        }
        if let followers = user.counters?.followers {
            followersCountLabel.text = "\(followers)"
        }
        if let username = user.screenName ?? user.firstName {
            nicknameLabel.text = username
        }
    }
    
    func setCurrentContentOffset(offset: CGPoint) {
        proposedContentOffset = offset
    }
    
    func viewControllerWillReleased() {
        presenter?.releaseDownloadSession()
    }
    
    func insertNewPost(post: Post) {
        posts.insert(post, at: 0)
        imageCollectionView.performBatchUpdates({
            self.imageCollectionView.insertItems(at: [IndexPath(item: 0, section: 0)])
        }) { (completion) in
        }
    }
}

extension GalleryViewController: UIScrollViewDelegate {
    
    var endScrollRecommendedOffset: CGFloat {
        if let layout = imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.itemSize.height * Constants.recomendetOffsetMultiplier
        }
        return 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mainScrollView {
            let contentOffset = scrollView.contentOffset
            if scrollView.contentOffset.y < headerView.frame.height {
                topOffset.constant = -contentOffset.y
                if imageCollectionView.contentOffset.y != 0 {
                    imageCollectionView.contentOffset = CGPoint(x: 0, y: 0)
                }
                headerView.isHidden = false
                view.layoutIfNeeded()
            } else if scrollView.contentOffset.y >= headerView.frame.height {
                headerView.isHidden = true
                topOffset.constant = -headerView.frame.height
                imageCollectionView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y - headerView.frame.height)
                view.layoutIfNeeded()
            }
            let currentOffset = scrollView.contentOffset.y + scrollView.frame.size.height
            let maximumOffset = scrollView.contentSize.height
            let deltaOffset = maximumOffset - currentOffset
            if deltaOffset <= endScrollRecommendedOffset {
                presenter?.nextFetch()
            }
        }
    }
}

extension GalleryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.galleryCollectionViewFooterIdentifier, for: indexPath) as? GalleryCollectionFooterView else { fatalError() }
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: Constants.footerViewHeight)
    }
}

extension GalleryViewController: UICollectionViewDelegateFlowLayout {
}

extension GalleryViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if flowLayout.cellType == .Grid {
            guard let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: Constants.gridItemIdentifier, for: indexPath) as? GridCollectionViewCell else { fatalError() }
            cell.vc = self
            return cell
        } else if flowLayout.cellType == .Tape {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.tapeItemIdentifier, for: indexPath) as? TapeCollectionViewCell else { fatalError() }
            cell.vc = self
            return cell
        }
        return UICollectionViewCell(frame: .null)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        if flowLayout.cellType == .Grid {
            guard let cell = cell as? GridCollectionViewCell else { fatalError() }
            cell.configure(postData: post)
        } else if flowLayout.cellType == .Tape {
            guard let cell = cell as? TapeCollectionViewCell else { fatalError() }
            cell.configure(postData: post)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if presenter?.checkIsAllLoaded() == true {
            if let footer = view as? GalleryCollectionFooterView {
                footer.allDownloaded()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard flowLayout.cellType == .Grid else { return }
        setTapeMode()
        if posts.count - 1 == indexPath.row {
            if let height = imageCollectionView.layoutAttributesForItem(at: indexPath)?.bounds.height {
                let contentOffset = CGPoint(x: 0, y: imageCollectionView.contentSize.height - height - headerView.frame.height - secondHeaderView.frame.height)
                mainScrollView.setContentOffset(contentOffset, animated: false)
            }
        } else {
            if let center = imageCollectionView.layoutAttributesForItem(at: indexPath)?.center {
                mainScrollView.setContentOffset(CGPoint(x: 0, y: center.y - headerView.frame.height - secondHeaderView.frame.height), animated: false)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = imageCollectionView.cellForItem(at: indexPath) as? GridCollectionViewCell {
            cell.layer.opacity = Constants.highlightedItemOpacity
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = imageCollectionView.cellForItem(at: indexPath) as? GridCollectionViewCell {
            cell.layer.opacity = Constants.normalItemOpacity
        }
    }
}

private extension GalleryViewController {
    func configureUI() {
        navigationController?.isNavigationBarHidden = true
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        mainScrollView.refreshControl = refreshControl
        mainScrollView.alwaysBounceVertical = true
        gridModeButton.isSelected = true
        addPostView.layer.cornerRadius = addPostView.bounds.width / 2
        addPostView.layer.shadowRadius = Constants.shadowRadius
        addPostView.layer.shadowOpacity = Constants.defaultShadowOpacity
        addPostView.layer.shadowOffset = CGSize(width: 0, height: 2)
        secondHeaderView.layer.shadowOpacity = Constants.defaultShadowOpacity
        secondHeaderView.layer.shadowOffset = CGSize(width: Constants.shadowOffsetWidth, height: secondHeaderView.frame.height / Constants.shadowOffsetHeightMultiplier)
        secondHeaderView.layer.shadowRadius = Constants.shadowRadius
        mainScrollView.frame = view.frame
        let scrollViewContentSize = CGSize(width: view.frame.width, height: headerView.frame.height + headerViewBottom.accessibilityFrame.height + secondHeaderView.frame.height + secondHeaderBottom.accessibilityFrame.height + imageCollectionView.contentSize.height)
        mainScrollView.contentSize = scrollViewContentSize
        mainScrollView.contentInsetAdjustmentBehavior = .never
        mainScrollView.showsVerticalScrollIndicator = false
        view.addGestureRecognizer(mainScrollView.panGestureRecognizer)
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        
        if !Reachability.isConnectedToNetwork() {
            showToast(message: Constants.internetConnectionErrorMessage)
        }
    }
    
    func configurePresentation() {
        let currentTheme = ThemeService.currentTheme()
        let primary = currentTheme.primaryColor
        let secondary = currentTheme.secondaryColor
        let background = currentTheme.backgroundColor
        let secondaryBackground = currentTheme.secondaryBackgroundColor
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = background
        friendsCountLabel.textColor = primary
        friendsLabel.textColor = primary
        followersCountLabel.textColor = primary
        followersLabel.textColor = primary
        nicknameLabel.textColor = primary
        secondHeaderView.backgroundColor = secondaryBackground
        addPostView.backgroundColor = background
        addPostButton.tintColor = primary
        tapeModeButton.tintColor = primary
        gridModeButton.tintColor = primary
        settingsButton.tintColor = primary
        tapeStateIndicator.backgroundColor = primary
        gridStateIndicator.backgroundColor = primary
        guard let cells = imageCollectionView.visibleCells as? [TapeCollectionViewCell] else { return }
        for cell in cells {
            cell.configureUI()
        }
    }
    
    func setGridMode() {
        if flowLayout.cellType != .Grid {
            flowLayout.cellType = .Grid
            tapeModeButton.isSelected = false
            gridModeButton.isSelected = true
            imageCollectionView.reloadData()
            setGridFlowLayout()
        }
    }
    
    func setTapeMode() {
        if flowLayout.cellType != .Tape {
            flowLayout.cellType = .Tape
            tapeModeButton.isSelected = true
            gridModeButton.isSelected = false
            imageCollectionView.reloadData()
            changeFlowLayout()
        }
    }
    
    func changeFlowLayout() {
        UIView.animate(withDuration: Constants.changeTapsAnimationDuration) {
            self.tapeStateIndicator.alpha = 1.0
            self.tapeModeButton.alpha = 1.0
            self.gridStateIndicator.alpha = Constants.deselectedTapAlpha
            self.gridModeButton.alpha = Constants.deselectedTapAlpha
        }
        imageCollectionView.setCollectionViewLayout(tapeFlowLayout, animated: false) { (finished) in
            if finished {                
                self.mainScrollView.contentOffset = self.proposedContentOffset ?? CGPoint(x: 0, y: 0)
                let scrollViewContentSize = CGSize(width: self.view.frame.width, height: self.headerView.frame.height + self.headerViewBottom.accessibilityFrame.height + self.secondHeaderView.frame.height + self.secondHeaderBottom.accessibilityFrame.height + self.imageCollectionView.collectionViewLayout.collectionViewContentSize.height)
                self.mainScrollView.contentSize = scrollViewContentSize
            }
        }
    }
    
    func setGridFlowLayout() {
        UIView.animate(withDuration: Constants.changeTapsAnimationDuration) {
            self.tapeStateIndicator.alpha = Constants.deselectedTapAlpha
            self.tapeModeButton.alpha = Constants.deselectedTapAlpha
            self.gridStateIndicator.alpha = 1.0
            self.gridModeButton.alpha = 1.0
        }
        imageCollectionView.setCollectionViewLayout(flowLayout, animated: false) { (finished) in
            if finished {
                self.mainScrollView.contentOffset = self.proposedContentOffset ?? CGPoint(x: 0, y: 0)
                let scrollViewContentSize = CGSize(width: self.view.frame.width, height: self.headerView.frame.height + self.headerViewBottom.accessibilityFrame.height + self.secondHeaderView.frame.height + self.secondHeaderBottom.accessibilityFrame.height + self.imageCollectionView.collectionViewLayout.collectionViewContentSize.height)
                self.mainScrollView.contentSize = scrollViewContentSize
            }
        }
    }
    
    @objc func refreshData(_ sender: UIRefreshControl) {
        presenter?.getProfile()
        presenter?.refreshPageService()
        offset = 0
        posts.removeAll()
        imageCollectionView.reloadData()
        presenter?.nextFetch()
        refreshControl.endRefreshing()
    }
}
