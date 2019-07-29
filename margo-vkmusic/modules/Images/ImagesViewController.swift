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
    func setFriends(friends: Int)
    func setFollowers(followers: Int)
    func getViewModeState() -> Int
}

class ImagesViewController: UIViewController {
    
    var presenter: ImagePresenterProtocol?
    var flowLayout: ImagesCollectionViewFlowLayout? = nil
    var images = [Image]()
    
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
            self.imageCollectionView.delegate = self
        }
    }
    @IBOutlet weak var mainScrollView: UIScrollView! {
        didSet {
            self.mainScrollView.delegate = self
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        configureUI()
    }
    
    func getViewModeState() -> Int {
        return self.flowLayout?.cellType ?? 0
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
        self.images = images
        imageCollectionView.reloadSections(IndexSet(integersIn: 0...0))
        let scrollViewContentSize = CGSize(width: view.frame.width, height: headerView.frame.height + headerViewBottom.accessibilityFrame.height + secondHeaderView.frame.height + secondHeaderBottom.accessibilityFrame.height + imageCollectionView.collectionViewLayout.collectionViewContentSize.height)
        mainScrollView.contentSize = scrollViewContentSize
        presenter?.imagesDownloaded()
    }
    
    func loadAvatar(image: UIImage) {
        DispatchQueue.main.async {
            self.avatarImageView.image = image
        }
    }
    
    func setFriends(friends: Int) {
        DispatchQueue.main.async {
            self.friendsCountLabel.text = "Friends: \(String(friends))"
        }
    }
    
    func setFollowers(followers: Int) {
        DispatchQueue.main.async {
            self.followersCountLabel.text = "Followers: \(String(followers))"
        }
    }
    
    func cellIsLoading(url: String, progress: @escaping (_ progress: Float) -> (), completion: @escaping (_ image: UIImage, _ url: String) -> ()) {
        presenter?.loadImage(url: url, progress: progress, completion: completion)
    }
}

extension ImagesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var endScrollRecommendedOffset: CGFloat {
            if let layout = imageCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                return layout.itemSize.height * 3
            }
            return 0
        }
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
                presenter?.getPhotosUrl()
            }
        }
    }
}

extension ImagesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
}

extension ImagesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "imgCell"
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ImageCollectionViewCell
        //let image = images[indexPath.row]
        cell?.vc = self
        //cell?.configure(imageData: image)
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let image = images[indexPath.row]
        let cell = cell as! ImageCollectionViewCell
        cell.configure(imageData: image)
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
        self.navigationController?.isNavigationBarHidden = true
        gridModeButton.setTitleColor(UIColor.black, for: .selected)
        tapeModeButton.setTitleColor(UIColor.black, for: .selected)
        gridModeButton.isSelected = true
        if let layout = imageCollectionView.collectionViewLayout as? ImagesCollectionViewFlowLayout {
            flowLayout = layout
            flowLayout?.vc = self
        }
        imageCollectionView.backgroundColor = UIColor.white
        mainScrollView.frame = self.view.frame
        let scrollViewContentSize = CGSize(width: view.frame.width, height: headerView.frame.height + headerViewBottom.accessibilityFrame.height + secondHeaderView.frame.height + secondHeaderBottom.accessibilityFrame.height + imageCollectionView.contentSize.height)
        mainScrollView.contentSize = scrollViewContentSize
        mainScrollView.contentInsetAdjustmentBehavior = .never
        self.view.addGestureRecognizer(mainScrollView.panGestureRecognizer)
        imageCollectionView.delegate = self
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.layer.borderColor = UIColor.darkGray.cgColor
        avatarImageView.layer.borderWidth = 4
        avatarImageView.layer.shadowRadius = 10
        imageCollectionView.backgroundColor = UIColor(white: 1, alpha: 0)
        self.view.setGradientBackground(firstColor: UIColor.darkGray, secondColor: UIColor.lightGray)
    }
    
    func setGridMode() {
        if flowLayout?.cellType != 0 {
            flowLayout?.setGridView()
            tapeModeButton.isSelected = false
            gridModeButton.isSelected = true
        }
    }
    
    func setTapeMode() {
        if flowLayout?.cellType != 1 {
            flowLayout?.setTapeView()
            tapeModeButton.isSelected = true
            gridModeButton.isSelected = false
        }
    }
}
