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
    //func startUploadPhoto(data: Data, fileName: String, progress: @escaping Update, completion: @escaping PostUploadCompletion)
    //func photoDidUpload(id: Int)
    //func cancelUpload(id: Int?, fileName: String, completion: @escaping CancelCompletion)
    func uploadComplete(at index: Int, id: Int)
    func setProgress(at index: Int, progress: Float)
    func deleteCell(at index: Int)
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
    var itemToUploadCount = 0
    var selectedItems = [Int]()
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        navigationController?.isToolbarHidden = true
        if pickerCollectionView.alpha == 1.0 {
            hidePickerView()
        }
        subscribeKeyboardObserver()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardObserver()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            presenter?.invalidateSession()
        }
    }
    
    @IBAction func addPhotoButtonPressed(_ sender: UIButton) {
        presentPickerView()
    }
    
    @IBAction func closePickerButtonPressed(_ sender: UIButton) {
        hidePickerView()
        var assets = [PHAsset]()
        for item in selectedItems {
            guard let asset = photosFromGallery?.object(at: item) else { return }
            assets.append(asset)
        }
        pickComplete(assets: assets)
        selectedItems.removeAll()
        photoPickerCollectionView.reloadData()
    }
    
    @IBAction func openGalleryButton(_ sender: UIButton) {
        presenter?.presentGallery()
    }
}

extension UploadPostViewController: UploadPostViewControllerProtocol {
    func deleteCell(at index: Int) {
        selectedImagesCollectionView.deleteItems(at: [IndexPath(item: index, section: 0)])
    }
    
    func pickComplete(assets: [PHAsset]) {
        presenter?.updateDataSource(assets: assets)
        selectedImagesCollectionView.reloadData()
    }
    
    func uploadComplete(at index: Int, id: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        guard selectedImagesCollectionView.indexPathsForVisibleItems.contains(indexPath),
            let item = selectedImagesCollectionView.cellForItem(at: indexPath) as? UploadPostSelectedCell
            else { return }
        item.uploadComplete()
    }

    func setProgress(at index: Int, progress: Float) {
        let indexPath = IndexPath(item: index, section: 0)
        guard selectedImagesCollectionView.indexPathsForVisibleItems.contains(indexPath),
            let item = selectedImagesCollectionView.cellForItem(at: indexPath) as? UploadPostSelectedCell
            else { return }
        item.updateProgress(progress: progress)
    }
    
}

extension UploadPostViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == pickerCollectionView {
            guard let galleryPhotosCount = photosFromGallery?.count else { return 0 }
            if galleryPhotosCount < 31 {
                return galleryPhotosCount + 1
            }
            return 30 + 1
        } else if collectionView == selectedImagesCollectionView {
            guard let photosCount = presenter?.getCountOfUploadItems() else { return 0 }
            return photosCount
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == pickerCollectionView {
            guard let photosCount = photosFromGallery?.count else { fatalError() }
            if indexPath.item == collectionView.numberOfItems(inSection: 0) - 1 {
                let cellIdentifier = Constants.openGalleryCollectionViewCell
                guard let cell = photoPickerCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? OpenMoreCollectionViewCell else { fatalError(Constants.collectionViewInitFatalErrorDescription) }
                return cell
            }
            if indexPath.item < photosCount {
                let cellIdentifier = Constants.pickerCollectionViewCellReuseIdentifier
                guard let cell = photoPickerCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? AlbumUploadCollectionViewCell else { fatalError(Constants.collectionViewInitFatalErrorDescription) }
                guard let asset = photosFromGallery?.object(at: indexPath.item) else { fatalError() }
                cell.configureCell(asset: asset, cellSize: bigFlowLayout.itemSize)
                if let k = selectedItems.firstIndex(of: indexPath.item) {
                    cell.setSerialNumber(number: k + 1)
                    collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                }
                return cell
            }
        } else if collectionView == selectedImagesCollectionView {
            let cellIdentifier = Constants.selectedImageCollectionViewCellReuseIdentifier
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as? UploadPostSelectedCell else {
                fatalError(Constants.collectionViewInitFatalErrorDescription) }
            guard let uploadPhoto = presenter?.getUploadImage(at: indexPath) else { fatalError(Constants.collectionViewInitFatalErrorDescription) }
            cell.asset = uploadPhoto.asset
            cell.vc = self
            cell.configureCell()
            return cell
        }
        return UICollectionViewCell(frame: .null)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        if collectionView == pickerCollectionView {
            if indexPath.item == pickerCollectionView.numberOfItems(inSection: 0) - 1 {
                presenter?.presentGallery()
                collectionView.reloadData()
                return
            }
            if selectedItems.contains(indexPath.item) {
                guard let item = collectionView.cellForItem(at: indexPath) as? AlbumUploadCollectionViewCell else { return }
                if let i = selectedItems.firstIndex(of: indexPath.item) {
                    selectedItems.remove(at: i)
                }
                item.removeSerialNumber()
                collectionView.reloadData()
            } else {
                guard let item = collectionView.cellForItem(at: indexPath) as? AlbumUploadCollectionViewCell else { return }
                selectedItems.append(indexPath.item)
                item.setSerialNumber(number: selectedItems.count)
            }
        } else if collectionView == selectedImagesCollectionView {
            presenter?.cancelUpload(index: indexPath.item)
        }
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
        photoPickerCollectionView.alpha = 0
        closePhotoPickerButton.alpha = 0
        photoPickerCollectionView.allowsMultipleSelection = true
        photoPickerCollectionView.collectionViewLayout = smallFlowLayout
        selectedImagesCollectionView.backgroundColor = UIColor.black
        let doneBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneBarButtonItemPressed))
        navigationItem.rightBarButtonItem = doneBarButtonItem
        let keyboardToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.height, height: 50))
        keyboardToolbar.barStyle = .default
        let doneBarKeyboardItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(hideKeyboard))
        keyboardToolbar.items = [doneBarKeyboardItem]
        keyboardToolbar.sizeToFit()
        textView.inputAccessoryView = keyboardToolbar
        
        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        photosFromGallery = PHAsset.fetchAssets(with: allPhotosOptions)
        photoPickerCollectionView.reloadData()
    }
    
    func subscribeKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func hidePickerView() {
        self.photoPickerViewBottomConstraint.constant -= 150
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.pickerCollectionView.alpha = 0
            self.closePhotoPickerButton.alpha = 0
        }) { (complete) in
            if complete {
                
            }
        }
    }
    
    func presentPickerView() {
        self.photoPickerViewBottomConstraint.constant += 150
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            self.pickerCollectionView.alpha = 1.0
            self.closePhotoPickerButton.alpha = 1.0
        }) { (complete) in
            if complete {
            }
        }
    }
    
    @objc func doneBarButtonItemPressed() {
        let message = textView.text
        presenter?.uploadPost(message: message, completion: { (id) in
        }, createPostCompletion: { (post) in
            self.presenter?.moveBack(newPost: post)
        })
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        guard let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        //if photoPickerCollectionView.isHidden {
        //    photoPickerViewBottomConstraint.constant = keyboardFrame.size.height - photoPickerCollectionView.bounds.height - 35
        //} else {
        //    photoPickerViewBottomConstraint.constant = keyboardFrame.size.height - 35
        //}
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        //if photoPickerCollectionView.isHidden {
        //    photoPickerViewBottomConstraint.constant = -photoPickerCollectionView.bounds.height
        //} else {
        //    photoPickerViewBottomConstraint.constant = 0
        //}
    }
}
