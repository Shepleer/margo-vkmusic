//
//  MusicPlayerViewController.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/2/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol ImagesViewControllerProtocol: class {
    func configureWithPhotos(images: [Image])
    func loadAvatar(image: UIImage)
    func setProfileData(user: User)
    func setLike(photo: Image, completion: @escaping (_ likes: Int) -> ())
    func removeLike(photo: Image, completion: @escaping (_ likes: Int) -> ())
    func fetchPhotoData(photoData: Image, completion: @escaping CommentsCompletion)
    func moveToDetailPhotoScreen(photo: Image)
}

class ImagesViewController: UIViewController {
    
    var presenter: ImagePresenterProtocol?
    var flowLayout: ImagesCollectionViewFlowLayout? = nil
    var images = [Image]()
    var profile: User? = nil
    var avatarImage: UIImage? = nil
    var router: ImagesRouter?
    private let photosCollectionViewFooterIdentifier = "photosFooter"
    
    @IBOutlet weak var activityViewTopOffset: NSLayoutConstraint!
    @IBOutlet weak var activityView: UIView!
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
        //imageCollectionView.register(PhotosCollectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: photosCollectionViewFooterIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func getViewModeState() -> CellType {
        return flowLayout?.cellType ?? CellType.Grid
    }
    
    func cancellingDownload(image: Image) {
        presenter?.cancelDownload(image: image)
    }
    
    @IBAction func gridModeButtonTapped(_ sender: UIButton) {
        setGridMode()
    }
    
    @IBAction func tapeModeButtonTapped(_ sender: UIButton) {
        setTapeMode()
    }
    
    func changeViewMode() {
        flowLayout?.prepare()
        let scrollViewContentSize = CGSize(width: view.frame.width, height: headerView.frame.height + headerViewBottom.accessibilityFrame.height + secondHeaderView.frame.height + secondHeaderBottom.accessibilityFrame.height + imageCollectionView.collectionViewLayout.collectionViewContentSize.height)
        mainScrollView.contentSize = scrollViewContentSize
    }
}

extension ImagesViewController: ImagesViewControllerProtocol {
    func configureWithPhotos(images: [Image]) {
        self.images.append(contentsOf: images)
        imageCollectionView.reloadSections(IndexSet(integer: 0))
        let scrollViewContentSize = CGSize(width: view.frame.width, height: headerView.frame.height + headerViewBottom.accessibilityFrame.height + secondHeaderView.frame.height + secondHeaderBottom.accessibilityFrame.height + imageCollectionView.collectionViewLayout.collectionViewContentSize.height)
        mainScrollView.contentSize = scrollViewContentSize
        presenter?.imagesDownloaded()
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
    
    func fetchPhotoData(photoData: Image, completion: @escaping CommentsCompletion) {
        presenter?.fetchComments(photoData: photoData, completion: completion)
    }
    
    func cellIsLoading(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ()) {
        presenter?.loadImage(url: url, progress: progress, completion: completion)
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
    
    func setLike(photo: Image, completion: @escaping LikesCountCompletion) {
        presenter?.setLike(photo: photo, completion: completion)
    }
    
    func removeLike(photo: Image, completion: @escaping LikesCountCompletion) {
        presenter?.removeLike(photo: photo, completion: completion)
    }
    
    func moveToDetailPhotoScreen(photo: Image) {
        profile?.avatarImage = avatarImage
        router?.moveToDetailScreen(photo: photo, profile: profile!)
    }
    
    func disableScrollView() {
        mainScrollView.isScrollEnabled = false
    }
    
    func enableScrollView() {
        mainScrollView.isScrollEnabled = true
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
        return images.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: photosCollectionViewFooterIdentifier, for: indexPath) as! PhotosCollectionFooterView
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
        if flowLayout?.cellType == .Grid {
            let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ImageCollectionViewCell
            cell?.vc = self
            return cell!
        } else if flowLayout?.cellType == .Tape {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tapeCellIdentifier, for: indexPath) as? TapeCollectionViewCell
            cell?.vc = self
            return cell!
        }
        return UICollectionViewCell(frame: .null)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let image = images[indexPath.row]
        if flowLayout?.cellType == .Grid {
            let cell = cell as! ImageCollectionViewCell
            cell.configure(imageData: image)
        } else if flowLayout?.cellType == .Tape {
            let cell = cell as! TapeCollectionViewCell
            cell.configure(imageData: image)
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
        if let center = imageCollectionView.layoutAttributesForItem(at: indexPath)?.center {
            mainScrollView.setContentOffset(CGPoint(x: 0, y: center.y - headerView.frame.height - secondHeaderView.frame.height), animated: false)
        }
    }
}

private extension ImagesViewController {
    func configureUI() {
        navigationController?.isNavigationBarHidden = true
        gridModeButton.isSelected = true
        if let layout = imageCollectionView.collectionViewLayout as? ImagesCollectionViewFlowLayout {
            flowLayout = layout
            flowLayout?.vc = self
        }
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
        if flowLayout?.cellType != .Grid {
            flowLayout?.cellType = .Grid
            changeViewMode()
            tapeModeButton.isSelected = false
            gridModeButton.isSelected = true
            imageCollectionView.reloadSections(IndexSet(integer: 0))
        }
    }
    
    func setTapeMode() {
        if flowLayout?.cellType != .Tape {
            flowLayout?.cellType = .Tape
            changeViewMode()
            tapeModeButton.isSelected = true
            gridModeButton.isSelected = false
            imageCollectionView.reloadSections(IndexSet(integer: 0))
        }
    }
}
