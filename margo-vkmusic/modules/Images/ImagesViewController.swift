//
//  MusicPlayerViewController.swift
//  margo-vkmusic
//
//  Created by Ivan Shpileuski on 7/2/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

class ImagesViewController: UIViewController {
    
    var presenter: ImagePresenter?

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
    
    
    func configureWithPhotos() {
        imageCollectionView.reloadData()
        view.layoutIfNeeded()
        mainScrollView.contentSize = CGSize(width: view.frame.width, height: headerView.frame.height + headerViewBottom.accessibilityFrame.height + secondHeaderView.frame.height + secondHeaderBottom.accessibilityFrame.height + imageCollectionView.contentSize.height)
    }
}

extension ImagesViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == mainScrollView {
            let contentOffset = scrollView.contentOffset
            if scrollView.contentOffset.y < headerView.frame.height {
                topOffset.constant = -contentOffset.y
                if imageCollectionView.contentOffset.y != 0 {
                    imageCollectionView.contentOffset = CGPoint(x: 0, y: 0)
                }
                view.layoutIfNeeded()
            } else if scrollView.contentOffset.y >= headerView.frame.height {
                topOffset.constant = -headerView.frame.height
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
        cell?.configure(data: image!)
        return cell!
    }
}

private extension ImagesViewController {
    func configureUI() {
        self.view.layoutIfNeeded()
        imageCollectionView.backgroundColor = UIColor.white
        mainScrollView.frame = self.view.frame
        mainScrollView.contentSize = CGSize(width: view.frame.width, height: headerView.frame.height + headerViewBottom.accessibilityFrame.height + secondHeaderView.frame.height + secondHeaderBottom.accessibilityFrame.height + imageCollectionView.contentSize.height)
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
    }
}
