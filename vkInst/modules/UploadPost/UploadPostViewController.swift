//
//  UploadPostViewController.swift
//  vkInst
//
//  Created by Ivan Shpileuski on 8/13/19.
//  Copyright © 2019 Ivan Shpileuski. All rights reserved.
//

import UIKit
import Photos

protocol UploadPostViewControllerProtocol: class {
    func pickComplete(assets: [PHAsset])
}

class UploadPostViewController: UIViewController {
    
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var closePhotoPickerButton: UIButton!
    @IBOutlet weak var photoPickerCollectionView: UICollectionView!
    @IBOutlet weak var toolBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var toolBar: UIView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var photoPickerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var openGalleryButton: UIButton!
    @IBOutlet weak var selectedImagesCollectionView: UICollectionView!
    @IBOutlet weak var pickerCollectionView: UICollectionView!
    
    private struct Constants {
        static let pickerCollectionViewCellReuseIdentifier = "galleryPhotoCell"
        static let selectedImageCollectionViewCellReuseIdentifier = "uploadPostSelectedCell"
        static let openGalleryCollectionViewCell = "openGalleryCell"
        static let collectionViewInitFatalErrorDescription = "Unexpected cell in collection view"
        
    }
    
    
    
    
    var smallFlowLayout = SmallPhotoPickerFlowLayout()
    var bigFlowLayout = BigPhotoPickerFlowLayout()
    var photosFromGallery: PHFetchResult<PHAsset>?
    var presenter: UploadPostPresenterProtocol?
    var selectedAssets = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUIPresentation()
        subscribeKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }
    
    @IBAction func addPhotoButtonPressed(_ sender: UIButton) {
        if photoPickerCollectionView.isHidden {
            photoPickerCollectionView.isHidden = false
            photoPickerViewBottomConstraint.constant = 0
            closePhotoPickerButton.isHidden = false
        }
    }
    
    @IBAction func closePickerButtonPressed(_ sender: UIButton) {
        if !photoPickerCollectionView.isHidden {
            photoPickerViewBottomConstraint.constant += 150
            photoPickerCollectionView.isHidden = true
            closePhotoPickerButton.isHidden = true
        }
        //presenter?.uploadImages(images: selectedImages)
        photoPickerCollectionView.reloadSections(IndexSet(integer: 0))
    }
    
    @IBAction func openGalleryButton(_ sender: UIButton) {
        presenter?.presentGallery()
    }
}

extension UploadPostViewController: UploadPostViewControllerProtocol {
    func addSelectedImage(image: UIImage) {
        //selectedImages.append(image)
    }
    
    func removeSelectedImage(image: UIImage) {
        //guard let i = selectedImages.firstIndex(of: image) else { return }
        //selectedImages.remove(at: i)
    }
    
    func pickComplete(assets: [PHAsset]) {
        print(assets)
    }
}

extension UploadPostViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == pickerCollectionView {
            guard let photosCount = photosFromGallery?.count else { return 0 }
            return 30 + 1
        } else if collectionView == selectedImagesCollectionView {
            return selectedAssets.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == pickerCollectionView {
            guard let photosCount = photosFromGallery?.count else { fatalError() }
            if indexPath.item == 30 {
                let cellIdentifier = Constants.openGalleryCollectionViewCell
                guard let cell = photoPickerCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? OpenMoreCollectionViewCell else { fatalError(Constants.collectionViewInitFatalErrorDescription) }
                return cell
            }
            if indexPath.item <= photosCount{
                let cellIdentifier = Constants.pickerCollectionViewCellReuseIdentifier
                guard let cell = photoPickerCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? AlbumUploadCollectionViewCell else { fatalError(Constants.collectionViewInitFatalErrorDescription) }
                guard let asset = photosFromGallery?.object(at: indexPath.item) else { fatalError() }
            
                cell.configureCell(asset: asset, cellSize: bigFlowLayout.itemSize)
                return cell
            }
        } else if collectionView == selectedImagesCollectionView {
            let cellIdentifier = Constants.selectedImageCollectionViewCellReuseIdentifier
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? UploadPostSelectedCell else {
                fatalError(Constants.collectionViewInitFatalErrorDescription) }
            return cell
        }
        return UICollectionViewCell(frame: .null)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == 30 {
            presenter?.presentGallery()
            collectionView.deselectItem(at: indexPath, animated: false)
            return
        }
        guard let item = collectionView.cellForItem(at: indexPath) as? AlbumUploadCollectionViewCell else { return }
        //updateCollectionViewPresentationIfNeedet()
        item.updateUI()
        guard let img = item.getImage() else { return }
        addSelectedImage(image: img)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let item = collectionView.cellForItem(at: indexPath) as? AlbumUploadCollectionViewCell else { return }
        //updateCollectionViewPresentationIfNeedet()
        
        item.updateUI()
        guard let img = item.getImage() else { return }
        removeSelectedImage(image: img)
    }
}

private extension UploadPostViewController {
    func updateCollectionViewPresentationIfNeedet() {
        guard let countOfVisibleItems = photoPickerCollectionView.indexPathsForSelectedItems else { return }
        if countOfVisibleItems.isEmpty {
            if photoPickerCollectionView.collectionViewLayout == bigFlowLayout {
                photoPickerCollectionView.setCollectionViewLayout(smallFlowLayout, animated: true)
                collectionViewHeightConstraint.constant = 150
                photoPickerCollectionView.layoutIfNeeded()
            }
        } else {
            if photoPickerCollectionView.collectionViewLayout == smallFlowLayout {
                photoPickerCollectionView.setCollectionViewLayout(bigFlowLayout, animated: true)
                collectionViewHeightConstraint.constant = 357
                photoPickerCollectionView.layoutIfNeeded()
            }
        }
    }
    
    func configureUI() {
        photoPickerCollectionView.isHidden = true
        closePhotoPickerButton.isHidden = true
        photoPickerCollectionView.allowsMultipleSelection = true
        photoPickerCollectionView.collectionViewLayout = smallFlowLayout
        
        selectedImagesCollectionView.allowsMultipleSelection = false
        selectedImagesCollectionView.backgroundColor = UIColor.black
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarButtonItemPressed))
        navigationItem.rightBarButtonItem = doneBarButtonItem
        
        navigationController?.isNavigationBarHidden = false
        
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        photosFromGallery = PHAsset.fetchAssets(with: allPhotosOptions)
        photoPickerCollectionView.reloadData()
    }
    
    func updateUIPresentation() {
        navigationController?.isToolbarHidden = true
        
    }
    
    func subscribeKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    @objc func doneBarButtonItemPressed() {
        let message = textView.text
        presenter?.uploadPost(message: message, completion: { _ in
            self.presenter?.moveBack()
        })
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        guard let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        if photoPickerCollectionView.isHidden {
            photoPickerViewBottomConstraint.constant = keyboardFrame.size.height - photoPickerCollectionView.bounds.height - 35
        } else {
            photoPickerViewBottomConstraint.constant = keyboardFrame.size.height - 35
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if photoPickerCollectionView.isHidden {
            photoPickerViewBottomConstraint.constant = -photoPickerCollectionView.bounds.height
        } else {
            photoPickerViewBottomConstraint.constant = 0
        }
    }
}
