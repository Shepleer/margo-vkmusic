//
//  MusicPlayerViewController.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/2/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol ImagesViewControllerProtocol: class {
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

protocol PhotosViewControllerCellDelegate: class {
    
}

class ImagesViewController: UIViewController {
    
    var presenter: ImagePresenterProtocol?
    var flowLayout: ImagesCollectionViewFlowLayout = ImagesCollectionViewFlowLayout()
    var tapeFlowLayout: TapeCollectionViewFlowLayout = TapeCollectionViewFlowLayout()
    var posts = [Post]()
    var profile: User? = nil
    var avatarImage: UIImage? = nil
    var isNeedFetchComments = true
    var offset: Int = 0
    var openedCellIndex: Int = 0
    
    private var proposedContentOffset: CGPoint? = nil
    private let photosCollectionViewFooterIdentifier = "photosFooter"
    
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
        imageCollectionView.register(UINib(nibName: "PhotosCollectionFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: photosCollectionViewFooterIdentifier)
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
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0.0
        rotationAnimation.toValue = Float.pi * 2.0
        rotationAnimation.duration = 1.5
        rotationAnimation.repeatCount = Float.infinity
        self.view.layer.add(rotationAnimation, forKey: "viewRotation")
        followersCountLabel.layer.add(rotationAnimation, forKey: "viewRotation")
        friendsCountLabel.layer.add(rotationAnimation, forKey: "viewRotation")
        avatarImageView.layer.add(rotationAnimation, forKey: "viewRotation")
        secondHeaderView.layer.add(rotationAnimation, forKey: "viewRotation")
        headerView.layer.add(rotationAnimation, forKey: "viewRotation")
        gridModeButton.layer.add(rotationAnimation, forKey: "viewRotation")
        tapeModeButton.layer.add(rotationAnimation, forKey: "viewRotation")
        for cell in imageCollectionView.visibleCells {
            cell.layer.add(rotationAnimation, forKey: "viewRotation")
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

extension ImagesViewController: ImagesViewControllerProtocol {
    
    func updatePostData(postId: Int, likesCount: Int, isUserLikes: Bool) {
        print("\(imageCollectionView.contentOffset.y) ---- \(mainScrollView.contentOffset.y)")
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
        self.offset = self.posts.count
        var indexPaths = [IndexPath]()
        for i in startOffset...offset - 1 {
            indexPaths.append(IndexPath(item: i, section: 0))
        }
        imageCollectionView.performBatchUpdates({
            print(offset)
            imageCollectionView.insertItems(at: indexPaths)
        }) { (complete) in
        }
        let scrollViewContentSize = CGSize(width: view.frame.width, height: headerView.frame.height + headerViewBottom.accessibilityFrame.height + secondHeaderView.frame.height + secondHeaderBottom.accessibilityFrame.height + imageCollectionView.collectionViewLayout.collectionViewContentSize.height)
        mainScrollView.contentSize = scrollViewContentSize
        presenter?.postsDownloaded()
    }
    
    func loadAvatar(image: UIImage) {
        avatarImageView.image = image
        UIView.animate(withDuration: 0.1) {
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
    
    func fetchPostData(postId: Int, ownerId: Int, completion: @escaping CommentsCompletion) {
        presenter?.fetchComments(postId: postId, ownerId: ownerId, completion: completion)
    }
    
    func cellIsLoading(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ()) {
        presenter?.loadImage(url: url, progress: progress, completion: completion)
    }
    
    func loadGif(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ()) {
        presenter?.loadGif(url: url, progress: progress, completion: completion)
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
    
    func disableScrollView() {
        mainScrollView.isScrollEnabled = false
    }
    
    func enableScrollView() {
        mainScrollView.isScrollEnabled = true
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

extension ImagesViewController: UIScrollViewDelegate {
    
    var endScrollRecommendedOffset: CGFloat {
        if let layout = imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            return layout.itemSize.height * 3
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
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == mainScrollView && (velocity.y >= 6 || velocity.y <= -6) {
            isNeedFetchComments = false
        } else {
            isNeedFetchComments = true
        }
    }
}

extension ImagesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: photosCollectionViewFooterIdentifier, for: indexPath) as? PhotosCollectionFooterView else { fatalError() }
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
}

extension ImagesViewController: UICollectionViewDelegateFlowLayout {
}

extension ImagesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "imgCell"
        let tapeCellIdentifier = "bigCell"
        if flowLayout.cellType == .Grid {
            guard let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ImageCollectionViewCell else { fatalError() }
            cell.vc = self
            return cell
        } else if flowLayout.cellType == .Tape {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tapeCellIdentifier, for: indexPath) as? TapeCollectionViewCell else { fatalError() }
            cell.vc = self
            return cell
        }
        return UICollectionViewCell(frame: .null)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let post = posts[indexPath.row]
        if flowLayout.cellType == .Grid {
            guard let cell = cell as? ImageCollectionViewCell else { fatalError() }
            cell.configure(postData: post)
        } else if flowLayout.cellType == .Tape {
            guard let cell = cell as? TapeCollectionViewCell else { fatalError() }
            cell.configure(postData: post)
            if isNeedFetchComments {
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if presenter?.checkIsAllLoaded() == true {
            if let footer = view as? PhotosCollectionFooterView {
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
        if let cell = imageCollectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
            cell.layer.opacity = 0.5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = imageCollectionView.cellForItem(at: indexPath) as? ImageCollectionViewCell {
            cell.layer.opacity = 1.0
        }
    }
}

private extension ImagesViewController {
    func configureUI() {
        navigationController?.isNavigationBarHidden = true
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        mainScrollView.refreshControl = refreshControl
        mainScrollView.alwaysBounceVertical = true
        gridModeButton.isSelected = true
        addPostView.layer.cornerRadius = addPostView.bounds.width / 2
        addPostView.layer.shadowRadius = 2
        addPostView.layer.shadowOpacity = 0.2
        addPostView.layer.shadowOffset = CGSize(width: 0, height: 2)
        secondHeaderView.layer.shadowOpacity = 0.2
        secondHeaderView.layer.shadowOffset = CGSize(width: 5, height: secondHeaderView.frame.height / 3)
        secondHeaderView.layer.shadowRadius = 30
        mainScrollView.frame = view.frame
        let scrollViewContentSize = CGSize(width: view.frame.width, height: headerView.frame.height + headerViewBottom.accessibilityFrame.height + secondHeaderView.frame.height + secondHeaderBottom.accessibilityFrame.height + imageCollectionView.contentSize.height)
        mainScrollView.contentSize = scrollViewContentSize
        mainScrollView.contentInsetAdjustmentBehavior = .never
        mainScrollView.showsVerticalScrollIndicator = false
        view.addGestureRecognizer(mainScrollView.panGestureRecognizer)
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
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
        UIView.animate(withDuration: 0.3) {
            self.tapeStateIndicator.alpha = 1.0
            self.tapeModeButton.alpha = 1.0
            self.gridStateIndicator.alpha = 0.5
            self.gridModeButton.alpha = 0.5
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
        UIView.animate(withDuration: 0.3) {
            self.tapeStateIndicator.alpha = 0.5
            self.tapeModeButton.alpha = 0.5
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
