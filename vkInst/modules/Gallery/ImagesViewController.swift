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
    func moveToDetailPhotoScreen(post: Post)
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
    var router: ImagesRouter?
    private var proposedContentOffset: CGPoint? = nil
    private let photosCollectionViewFooterIdentifier = "photosFooter"
    
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
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func getViewModeState() -> CellType {
        return flowLayout.cellType ?? CellType.Grid
    }
    
    func cancellingDownload(image: Image) {
        presenter?.cancelDownload(image: image)
    }
    
    @IBAction func gridModeButtonTapped(_ sender: UIButton) {
        setGridMode()
    }
    
    @IBAction func tapeModeButtonTapped(_ sender: UIButton) {
        setTapeMode()
        imageCollectionView.reloadData()
    }
    
    @IBAction func uploadPostButtonPressed(_ sender: UIButton) {
        router?.moveToUploadPostScreen()
    }
}

extension ImagesViewController: ImagesViewControllerProtocol {
    func configureWithPhotos(posts: [Post]) {
        self.posts.append(contentsOf: posts)
        imageCollectionView.reloadSections(IndexSet(integer: 0))
        let scrollViewContentSize = CGSize(width: view.frame.width, height: headerView.frame.height + headerViewBottom.accessibilityFrame.height + secondHeaderView.frame.height + secondHeaderBottom.accessibilityFrame.height + imageCollectionView.collectionViewLayout.collectionViewContentSize.height)
        mainScrollView.contentSize = scrollViewContentSize
        presenter?.postsDownloaded()
    }
    
    func loadAvatar(image: UIImage) {
        avatarImageView.image = image
        avatarImage = image
    }
    
    func setProfileData(user: User) {
        profile = user
        if let friends = user.counters?.friends {
            friendsCountLabel.text = "Friends: \(friends)"
        }
        if let followers = user.counters?.followers {
            followersCountLabel.text = "Followers: \(followers)"
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
    
    func moveToDetailPhotoScreen(post: Post) {
        profile?.avatarImage = avatarImage
        router?.moveToDetailScreen(post: post, profile: profile!)
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
            cell.fetchPhotoComments()
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
}

private extension ImagesViewController {
    func configureUI() {
        navigationController?.isNavigationBarHidden = true
        gridModeButton.isSelected = true
        
        mainScrollView.frame = view.frame
        let scrollViewContentSize = CGSize(width: view.frame.width, height: headerView.frame.height + headerViewBottom.accessibilityFrame.height + secondHeaderView.frame.height + secondHeaderBottom.accessibilityFrame.height + imageCollectionView.contentSize.height)
        mainScrollView.contentSize = scrollViewContentSize
        mainScrollView.contentInsetAdjustmentBehavior = .never
        view.addGestureRecognizer(mainScrollView.panGestureRecognizer)
        imageCollectionView.delegate = self
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.layer.borderColor = UIColor.darkGray.cgColor
        avatarImageView.layer.borderWidth = 4
        avatarImageView.layer.shadowRadius = 10
        view.setGradientBackground(firstColor: UIColor.darkGray, secondColor: UIColor.lightGray)
    }
    
    func setGridMode() {
        if flowLayout.cellType != .Grid {
            flowLayout.cellType = .Grid
            tapeModeButton.isSelected = false
            gridModeButton.isSelected = true
            imageCollectionView.reloadSections(IndexSet(integer: 0))
            setGridFlowLayout()
        }
    }
    
    func setTapeMode() {
        changeFlowLayout()
        if flowLayout.cellType != .Tape {
            flowLayout.cellType = .Tape
            tapeModeButton.isSelected = true
            gridModeButton.isSelected = false
            imageCollectionView.reloadSections(IndexSet(integer: 0))
            changeFlowLayout()
        }
    }
    
    func changeFlowLayout() {
        imageCollectionView.setCollectionViewLayout(tapeFlowLayout, animated: false) { (finished) in
            if finished {
                self.mainScrollView.contentOffset = self.proposedContentOffset ?? CGPoint(x: 0, y: 0)
                let scrollViewContentSize = CGSize(width: self.view.frame.width, height: self.headerView.frame.height + self.headerViewBottom.accessibilityFrame.height + self.secondHeaderView.frame.height + self.secondHeaderBottom.accessibilityFrame.height + self.imageCollectionView.collectionViewLayout.collectionViewContentSize.height)
                self.mainScrollView.contentSize = scrollViewContentSize
            }
        }
    }
    
    func setGridFlowLayout() {
        imageCollectionView.setCollectionViewLayout(flowLayout, animated: true) { (finished) in
            if finished {
                self.mainScrollView.contentOffset = self.proposedContentOffset ?? CGPoint(x: 0, y: 0)
                let scrollViewContentSize = CGSize(width: self.view.frame.width, height: self.headerView.frame.height + self.headerViewBottom.accessibilityFrame.height + self.secondHeaderView.frame.height + self.secondHeaderBottom.accessibilityFrame.height + self.imageCollectionView.collectionViewLayout.collectionViewContentSize.height)
                self.mainScrollView.contentSize = scrollViewContentSize
            }
        }
    }
}
