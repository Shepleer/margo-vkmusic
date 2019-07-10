//
//  MusicPlayerViewController.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/2/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol ImagesViewControllerProtocol: class {
    func configureWithPhotos()
    func loadAvatar(image: UIImage)
    func setFriends(friends: Int)
    func setFollowers(followers: Int)
}

class ImagesViewController: UIViewController {
    
    var presenter: ImagePresenterProtocol?
    
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    @IBOutlet weak var headerViewBottom: NSLayoutConstraint!
    @IBOutlet weak var secondHeaderBottom: NSLayoutConstraint!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var friendsCountLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var secondHeaderView: UIView!
    @IBOutlet weak var topOffset: NSLayoutConstraint!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    let mainScrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.getAllPhotos()
        presenter?.getAvatar()
        presenter?.viewDidLoad()
        configureUI()
    }
    
    func downloadImage(url: String, complection: @escaping (_ image: UIImage?,_ response: URLResponse?,_ error: Error?) -> ()) {
        presenter?.loadImage(url: url, complection: { (img, res, err) in
            complection(img, res, err)
        })
    }
}

extension ImagesViewController: ImagesViewControllerProtocol {
    func configureWithPhotos() {
        imageCollectionView.reloadData()
        view.layoutIfNeeded()
        let scrollViewContentSize = CGSize(width: view.frame.width, height: headerView.frame.height + headerViewBottom.accessibilityFrame.height + secondHeaderView.frame.height + secondHeaderBottom.accessibilityFrame.height + imageCollectionView.contentSize.height)
        mainScrollView.contentSize = scrollViewContentSize
    }
    
    func loadAvatar(image: UIImage) {
        avatarImageView.image = image
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
}

extension ImagesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mainScrollView {
            let contentOffset = scrollView.contentOffset
            if scrollView.contentOffset.y < headerView.frame.height {
                topOffset.constant = -contentOffset.y
                headerViewBottom.constant = 8
                if imageCollectionView.contentOffset.y != 0 {
                    imageCollectionView.contentOffset = CGPoint(x: 0, y: 0)
                }
                view.layoutIfNeeded()
            } else if scrollView.contentOffset.y >= headerView.frame.height {
                topOffset.constant -= secondHeaderView.frame.height
                headerViewBottom.constant += secondHeaderView.frame.height
                imageCollectionView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y - headerView.frame.height)
                view.layoutIfNeeded()
            }
        }
    }
}

extension ImagesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (presenter?.getCountOfCells())!
    }
}

extension ImagesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellIdentifier = "imgCell"
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? ImageCollectionViewCell
        let image = presenter?.getImage(indexPath: indexPath)
        cell?.data = image
        cell?.configure(vc: self)
        return cell!
    }
}

private extension ImagesViewController {
    func configureUI() {
        self.view.layoutIfNeeded()
        imageCollectionView.backgroundColor = UIColor.white
        mainScrollView.frame = self.view.frame
        let scrollViewContentSize = CGSize(width: view.frame.width, height: headerView.frame.height + headerViewBottom.accessibilityFrame.height + secondHeaderView.frame.height + secondHeaderBottom.accessibilityFrame.height + imageCollectionView.contentSize.height)
        mainScrollView.contentSize = scrollViewContentSize
        view.layoutIfNeeded()
        mainScrollView.isHidden = true
        mainScrollView.contentInsetAdjustmentBehavior = .never
        self.view.addSubview(mainScrollView)
        let view = UIView()
        view.frame = self.view.frame
        view.addGestureRecognizer(mainScrollView.panGestureRecognizer)
        self.view.addSubview(view)
        imageCollectionView.delegate = self
        self.mainScrollView.delegate = self
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        avatarImageView.layer.borderColor = UIColor.darkGray.cgColor
        avatarImageView.layer.borderWidth = 4
        avatarImageView.layer.shadowRadius = 10
        imageCollectionView.backgroundColor = UIColor(white: 1, alpha: 0)
        self.view.setGradientBackground(firstColor: UIColor.darkGray, secondColor: UIColor.lightGray)
    }
}
