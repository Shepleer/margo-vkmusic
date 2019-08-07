//
//  DetailPhotoViewController.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/2/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit

protocol DetailPhotoViewControllerProtocol {
    
}

class DetailPhotoViewController: UIViewController {

    var presenter: DetailPhotoPresenter?
    var imageData: Image?
    var profile: User?
    var comments = [Comment]()
    private var isZooming = false
    private var originalImageCenter: CGPoint?
    @IBOutlet weak var topOffset: NSLayoutConstraint!
    @IBOutlet weak var commentFieldBottomConstraint: NSLayoutConstraint!
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
    
    let placehol = UIImage(named: "placeholder")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        loadPhotoAndProfileData()
        invisibleScrollView.delegate = self
        configureUI()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func sendCommentButtonTapped(_ sender: UIButton) {
        if let comment = commentTextField.text {
            
            presenter?.sendComment(id: imageData!.id!, ownerId: imageData!.ownerId!, commentText: comment)
        }
        commentTextField.text = nil
        view.endEditing(true)
    }
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        if likeButton.isSelected {
            presenter?.removeLike(photo: imageData!, completion: { (likesCount) in
                self.imageData?.isLiked = false
                self.imageData?.likesCount = likesCount
                self.likeButton.isSelected = false
                self.likesCountLabel.text = "\(likesCount) likes"
            })
        } else {
            presenter?.setLike(photo: imageData!, completion: { (likesCount) in
                self.imageData?.isLiked = true
                self.imageData?.likesCount = likesCount
                self.likeButton.isSelected = true
                self.likesCountLabel.text = "\(likesCount) likes"
            })
        }
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
}

extension DetailPhotoViewController: DetailPhotoViewControllerProtocol {
    func configureDataSource(comments: [Comment]) {
        self.comments.append(contentsOf: comments)
        commentsTableView.reloadSections(IndexSet(integer: 0), with: .bottom)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
        if scrollView == invisibleScrollView {
            let contentOffset = scrollView.contentOffset
            topOffset.constant = -contentOffset.y
            
            let currentOffset = scrollView.contentOffset.y + scrollView.frame.size.height
            let maximumOffset = scrollView.contentSize.height
            let deltaOffset = maximumOffset - currentOffset
            if deltaOffset <= endScrollRecommendedOffset {
                guard let id = imageData?.id else { return }
                guard let ownerId = imageData?.ownerId else { return }
                presenter?.fetchComments(id: id, ownerId: ownerId)
            }
        }
    }
}

extension DetailPhotoViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

private extension DetailPhotoViewController {
    func loadPhotoAndProfileData() {
        photoImageView.image = imageData?.img
        likesCountLabel.text = "\(imageData!.likesCount!) likes"
        nicknameLabel.text = profile?.screenName
        avatarImageView.image = profile?.avatarImage
        
        if let comments = imageData?.comments {
            self.comments = comments
        }
        view.layoutIfNeeded()
    }
    
    func configureUI() {
        let scrollViewContentSize = CGSize(width: view.frame.width, height: commentsTableView.contentSize.height + photoContentView.frame.width - 70)
        invisibleScrollView.contentSize = scrollViewContentSize
        view.addGestureRecognizer(invisibleScrollView.panGestureRecognizer)
        self.navigationController?.isNavigationBarHidden = false
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
        if imageData!.isLiked! {
            likeButton.isSelected = true
        } else {
            likeButton.isSelected = false
        }
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(scale(sender:)))
        pinchGesture.delaysTouchesEnded = false
        pinchGesture.cancelsTouchesInView = false
        pinchGesture.delaysTouchesBegan = false
        photoImageView.addGestureRecognizer(pinchGesture)
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(doubleTapped(sender:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.delaysTouchesEnded = false
        doubleTapGesture.delaysTouchesBegan = false
        doubleTapGesture.cancelsTouchesInView = false
        photoImageView.addGestureRecognizer(doubleTapGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(photoScrolled(sender:)))
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        panGesture.cancelsTouchesInView = false
        panGesture.delegate = self
        photoImageView.addGestureRecognizer(panGesture)
    }
    
    @objc func doubleTapped(sender: UITapGestureRecognizer) {
        if !imageData!.isLiked! && sender.state == .ended {
            presenter?.setLike(photo: imageData!, completion: { (likesCount) in
                self.imageData?.isLiked = true
                self.imageData?.likesCount = likesCount
                self.likesCountLabel.text = "\(likesCount) likes"
                self.likeButton.isSelected = true
            })
        }
    }
    
    @objc func scale(sender: UIPinchGestureRecognizer) {
        if sender.state == .began {
            let currentScale = self.photoImageView.frame.size.width / self.photoImageView.bounds.size.width
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
            let currentScale = self.photoImageView.frame.size.width / self.photoImageView.bounds.size.width
            var newScale = currentScale*sender.scale
            if newScale < 1 {
                newScale = 1
                let transform = CGAffineTransform(scaleX: newScale, y: newScale)
                self.photoImageView.transform = transform
                sender.scale = 1
            }else {
                view.transform = transform
                sender.scale = 1
            }
        } else if sender.state == .ended || sender.state == .failed || sender.state == .cancelled {
            UIView.animate(withDuration: 0.3, animations: {
                self.photoImageView.transform = CGAffineTransform.identity
                guard let center = self.originalImageCenter else {return}
                self.photoImageView.center = center
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
            sender.setTranslation(CGPoint.zero, in: self.photoImageView.superview)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.commentFieldBottomConstraint.constant = -keyboardFrame.size.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.commentFieldBottomConstraint.constant = 0
    }
}
